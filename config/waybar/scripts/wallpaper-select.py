import sys
import os
import json
import subprocess
from pathlib import Path
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout,
                             QHBoxLayout, QListWidget, QListWidgetItem, QLabel,
                             QPushButton, QScrollArea, QFrame, QGridLayout,
                             QMessageBox, QSplitter, QComboBox, QLineEdit)
from PyQt5.QtCore import Qt, QSize, pyqtSignal, QThread, pyqtSignal
from PyQt5.QtGui import QPixmap, QIcon, QFont, QPalette, QColor


class WallpaperLoader(QThread):
    """异步加载壁纸信息的线程"""
    loaded = pyqtSignal(list)

    def __init__(self, wallpaper_dir):
        super().__init__()
        self.wallpaper_dir = Path(wallpaper_dir)

    def run(self):
        wallpapers = []
        try:
            # 遍历壁纸目录
            for item in self.wallpaper_dir.iterdir():
                if item.is_dir():
                    wallpaper_info = self.parse_wallpaper_info(item)
                    if wallpaper_info:
                        wallpapers.append(wallpaper_info)
        except Exception as e:
            print(f"加载壁纸时出错: {e}")

        self.loaded.emit(wallpapers)

    def parse_wallpaper_info(self, wallpaper_path):
        """解析壁纸信息"""
        try:
            # 查找json文件
            json_files = list(wallpaper_path.glob("*.json"))
            if not json_files:
                return None

            json_file = json_files[0]
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # 获取基本信息
            info = {
                'id': data.get('id', wallpaper_path.name),
                'title': data.get('title', wallpaper_path.name),
                'description': data.get('description', ''),
                'type': data.get('type', 'unknown'),
                'path': str(wallpaper_path),
                'preview': None
            }

            # 查找预览图
            preview_extensions = ['.jpg', '.jpeg', '.png', '.gif']
            for ext in preview_extensions:
                preview_files = list(wallpaper_path.glob(f"*{ext}"))
                if preview_files:
                    info['preview'] = str(preview_files[0])
                    break

            return info

        except Exception as e:
            print(f"解析壁纸信息失败 {wallpaper_path}: {e}")
            return None


class WallpaperItemWidget(QFrame):
    """单个壁纸项目控件"""
    clicked = pyqtSignal(dict)

    def __init__(self, wallpaper_info):
        super().__init__()
        self.wallpaper_info = wallpaper_info
        self.setup_ui()
        self.setStyleSheet("""
            WallpaperItemWidget {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                    stop:0 #3a3a3a, stop:1 #2a2a2a);
                border: 2px solid #555;
                border-radius: 8px;
                padding: 8px;
            }
            WallpaperItemWidget:hover {
                border: 2px solid #777;
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                    stop:0 #4a4a4a, stop:1 #3a3a3a);
            }
            QLabel {
                background: transparent;
                color: white;
            }
        """)

    def setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(8, 8, 8, 8)
        layout.setSpacing(6)

        # 预览图
        self.preview_label = QLabel()
        self.preview_label.setAlignment(Qt.AlignCenter)
        self.preview_label.setMinimumSize(200, 120)
        self.preview_label.setMaximumSize(300, 180)
        self.preview_label.setStyleSheet("""
            background: #1a1a1a;
            border: 1px solid #555;
            border-radius: 4px;
        """)

        # 加载预览图
        if self.wallpaper_info['preview']:
            pixmap = QPixmap(self.wallpaper_info['preview'])
            if not pixmap.isNull():
                scaled_pixmap = pixmap.scaled(280, 160, Qt.KeepAspectRatio, Qt.SmoothTransformation)
                self.preview_label.setPixmap(scaled_pixmap)
            else:
                self.preview_label.setText("无预览图")
        else:
            self.preview_label.setText("无预览图")

        # 标题
        title_label = QLabel(self.wallpaper_info['title'])
        title_label.setFont(QFont("Arial", 10, QFont.Bold))
        title_label.setAlignment(Qt.AlignCenter)
        title_label.setWordWrap(True)

        # 类型标签
        type_label = QLabel(f"类型: {self.wallpaper_info['type']}")
        type_label.setFont(QFont("Arial", 8))
        type_label.setAlignment(Qt.AlignCenter)
        type_label.setStyleSheet("color: #888;")

        layout.addWidget(self.preview_label)
        layout.addWidget(title_label)
        layout.addWidget(type_label)

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.clicked.emit(self.wallpaper_info)


class WallpaperEngine(QMainWindow):
    # 在WallpaperEngine类的__init__方法中添加壁纸引擎进程的引用
    def __init__(self):
        super().__init__()
        self.wallpapers = []
        self.current_filter = "all"
        self.wallpaper_engine_process = None  # 添加这一行
        self.setup_ui()
        self.load_wallpapers()
        # 连接窗口关闭事件
        self.closeEvent = self.on_close

    def setup_ui(self):
        """设置用户界面"""
        self.setWindowTitle("壁纸引擎 - Wallpaper Selector")
        self.setMinimumSize(1200, 700)

        # 设置深色主题
        self.set_dark_theme()

        # 创建中央控件
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        # 主布局
        main_layout = QHBoxLayout(central_widget)
        main_layout.setContentsMargins(10, 10, 10, 10)
        main_layout.setSpacing(10)

        # 创建分割器
        splitter = QSplitter(Qt.Horizontal)

        # 左侧面板
        left_panel = self.create_left_panel()
        splitter.addWidget(left_panel)

        # 右侧面板
        right_panel = self.create_right_panel()
        splitter.addWidget(right_panel)

        # 设置分割器比例
        splitter.setSizes([300, 900])

        main_layout.addWidget(splitter)

    def set_dark_theme(self):
        """设置深色主题"""
        self.setStyleSheet("""
            QMainWindow {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:1,
                    stop:0 #1e1e1e, stop:1 #2d2d2d);
            }
            QWidget {
                color: #ffffff;
            }
            QListWidget {
                background: #2d2d2d;
                border: 1px solid #555;
                border-radius: 5px;
                padding: 5px;
                outline: none;
            }
            QListWidget::item {
                padding: 8px;
                border-bottom: 1px solid #444;
            }
            QListWidget::item:selected {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                    stop:0 #4a4a4a, stop:1 #3a3a3a);
                border: 1px solid #666;
                border-radius: 3px;
            }
            QListWidget::item:hover {
                background: #3a3a3a;
            }
            QPushButton {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                    stop:0 #4a4a4a, stop:1 #3a3a3a);
                border: 1px solid #555;
                border-radius: 5px;
                padding: 8px 16px;
                color: white;
                font-weight: bold;
            }
            QPushButton:hover {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                    stop:0 #5a5a5a, stop:1 #4a4a4a);
                border: 1px solid #666;
            }
            QPushButton:pressed {
                background: qlineargradient(x1:0, y1:0, x2:0, y2:1,
                    stop:0 #3a3a3a, stop:1 #2a2a2a);
            }
            QLineEdit, QComboBox {
                background: #2d2d2d;
                border: 1px solid #555;
                border-radius: 5px;
                padding: 6px;
                color: white;
                font-size: 12px;
            }
            QScrollArea {
                border: none;
                background: transparent;
            }
            QLabel {
                color: white;
            }
        """)

    # 修改create_left_panel方法中的类型列表
    def create_left_panel(self):
        panel = QFrame()
        panel.setMaximumWidth(350)
        layout = QVBoxLayout(panel)
        layout.setContentsMargins(5, 5, 5, 5)
        layout.setSpacing(10)

        # 标题
        title = QLabel("壁纸引擎")
        title.setFont(QFont("Arial", 16, QFont.Bold))
        title.setAlignment(Qt.AlignCenter)
        title.setStyleSheet("color: #ffffff; margin: 10px;")

        # 搜索框
        search_layout = QHBoxLayout()
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("搜索壁纸...")
        self.search_input.textChanged.connect(self.filter_wallpapers)
        search_layout.addWidget(self.search_input)

        # 壁纸类型列表
        type_label = QLabel("壁纸类型")
        type_label.setFont(QFont("Arial", 12, QFont.Bold))

        self.type_list = QListWidget()
        self.type_list.addItems(["全部壁纸", "场景壁纸", "网页壁纸", "视频壁纸","其他壁纸"])
        self.type_list.currentRowChanged.connect(self.on_type_changed)
        self.type_list.setCurrentRow(0)

        # 控制按钮
        button_layout = QHBoxLayout()
        self.apply_btn = QPushButton("应用壁纸")
        self.apply_btn.clicked.connect(self.apply_wallpaper)
        self.apply_btn.setEnabled(False)

        self.refresh_btn = QPushButton("刷新列表")
        self.refresh_btn.clicked.connect(self.load_wallpapers)

        button_layout.addWidget(self.apply_btn)
        button_layout.addWidget(self.refresh_btn)

        # 添加到布局
        layout.addWidget(title)
        layout.addLayout(search_layout)
        layout.addWidget(type_label)
        layout.addWidget(self.type_list)
        layout.addStretch()
        layout.addLayout(button_layout)

        return panel

    def create_right_panel(self):
        """创建右侧壁纸展示面板"""
        panel = QFrame()
        layout = QVBoxLayout(panel)
        layout.setContentsMargins(5, 5, 5, 5)
        layout.setSpacing(10)

        # 标题
        self.panel_title = QLabel("全部壁纸")
        self.panel_title.setFont(QFont("Arial", 14, QFont.Bold))

        # 滚动区域
        self.scroll_area = QScrollArea()
        self.scroll_area.setWidgetResizable(True)
        self.scroll_area.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        self.scroll_area.setHorizontalScrollBarPolicy(Qt.ScrollBarAsNeeded)

        # 壁纸网格容器
        self.wallpaper_container = QWidget()
        self.grid_layout = QGridLayout(self.wallpaper_container)
        self.grid_layout.setSpacing(15)
        self.grid_layout.setAlignment(Qt.AlignTop)

        self.scroll_area.setWidget(self.wallpaper_container)

        # 当前选择显示
        self.selection_frame = QFrame()
        self.selection_frame.setVisible(False)
        self.selection_frame.setStyleSheet("""
            QFrame {
                background: #2d2d2d;
                border: 2px solid #555;
                border-radius: 8px;
                padding: 10px;
            }
        """)
        selection_layout = QVBoxLayout(self.selection_frame)

        self.selected_title = QLabel()
        self.selected_title.setFont(QFont("Arial", 12, QFont.Bold))

        self.selected_info = QLabel()
        self.selected_info.setFont(QFont("Arial", 9))
        self.selected_info.setWordWrap(True)

        selection_layout.addWidget(self.selected_title)
        selection_layout.addWidget(self.selected_info)

        layout.addWidget(self.panel_title)
        layout.addWidget(self.scroll_area)
        layout.addWidget(self.selection_frame)

        return panel

    def load_wallpapers(self):
        """加载壁纸列表"""
        # 默认壁纸目录，可以根据需要修改
        wallpaper_dirs = [
            Path.home() / "MyDisk/SteamLibrary/steamapps/workshop/content/431960",
        ]

        wallpaper_dir = None
        for dir_path in wallpaper_dirs:
            if dir_path.exists():
                wallpaper_dir = dir_path
                break

        if not wallpaper_dir:
            QMessageBox.warning(self, "警告", "未找到壁纸目录，请手动设置壁纸路径")
            return

        # 显示加载状态
        self.panel_title.setText("正在加载壁纸...")

        # 启动加载线程
        self.loader = WallpaperLoader(wallpaper_dir)
        self.loader.loaded.connect(self.on_wallpapers_loaded)
        self.loader.start()

    def on_wallpapers_loaded(self, wallpapers):
        """壁纸加载完成"""
        self.wallpapers = wallpapers
        self.display_wallpapers()
        self.panel_title.setText(f"全部壁纸 ({len(wallpapers)} 个)")

    def display_wallpapers(self):
        """显示壁纸网格"""
        # 清空现有内容
        for i in reversed(range(self.grid_layout.count())):
            self.grid_layout.itemAt(i).widget().setParent(None)

        # 过滤壁纸
        filtered_wallpapers = self.get_filtered_wallpapers()

        # 计算列数（基于容器宽度）
        container_width = self.scroll_area.width()
        item_width = 250  # 每个壁纸项的预估宽度
        columns = max(2, container_width // item_width)

        # 添加壁纸项
        row, col = 0, 0
        for wallpaper in filtered_wallpapers:
            item_widget = WallpaperItemWidget(wallpaper)
            item_widget.clicked.connect(self.on_wallpaper_selected)
            self.grid_layout.addWidget(item_widget, row, col)

            col += 1
            if col >= columns:
                col = 0
                row += 1

    def get_filtered_wallpapers(self):
        """获取筛选后的壁纸列表"""
        filtered = self.wallpapers.copy()

        # 类型筛选（不区分大小写）
        if self.current_filter != "all":
            filtered = [w for w in filtered if w['type'].lower() == self.current_filter]

        # 搜索筛选
        search_text = self.search_input.text().lower()
        if search_text:
            filtered = [w for w in filtered if
                        search_text in w['title'].lower() or
                        search_text in w['description'].lower()]

        return filtered

    def on_wallpaper_selected(self, wallpaper_info):
        """壁纸被选中"""
        self.selected_wallpaper = wallpaper_info
        self.apply_btn.setEnabled(True)

        # 显示选中信息
        self.selection_frame.setVisible(True)
        self.selected_title.setText(wallpaper_info['title'])

        info_text = f"""
        ID: {wallpaper_info['id']}
        类型: {wallpaper_info['type']}
        路径: {wallpaper_info['path']}
        """

        if wallpaper_info['description']:
            info_text += f"\n描述: {wallpaper_info['description']}"

        self.selected_info.setText(info_text)

    def on_type_changed(self, row):
        """类型列表变更"""
        type_map = {
            0: "all",
            1: "scene",
            2: "web",
            3: "video",
            4: "other"
        }

        if row in type_map:
            self.current_filter = type_map[row]
            # 检查grid_layout是否已初始化
            if hasattr(self, 'grid_layout'):
                self.display_wallpapers()

                # 更新标题
                titles = ["全部壁纸", "场景壁纸", "网页壁纸", "视频壁纸", "其他壁纸"]
                self.panel_title.setText(f"{titles[row]} ({len(self.get_filtered_wallpapers())} 个)")

    def on_filter_changed(self, text):
        """筛选器变更"""
        filter_map = {
            "全部": "all",
            "动态": "dynamic",
            "静态": "static",
            "视频": "video",
            "未知": "unknown"
        }

        if text in filter_map:
            self.current_filter = filter_map[text]
            self.display_wallpapers()

    def filter_wallpapers(self):
        """搜索筛选"""
        self.display_wallpapers()

    def apply_wallpaper(self):
        """应用选中的壁纸"""
        if not hasattr(self, 'selected_wallpaper'):
            return
    
        try:
            wallpaper_path = self.selected_wallpaper['path']
    
            # 使用linux-wallpaperengine命令设置壁纸
            # 添加nohup命令确保程序关闭后壁纸进程继续运行
            cmd = ["nohup", "linux-wallpaperengine", wallpaper_path, "--screen-root", "eDP-1", "--scaling", "fill", "&>", "/dev/null", "&"]
            # 改为后台启动linux-wallpaperengine，删除现有linux-wallpaperengine进程
            # 检查是否有正在运行的linux-wallpaperengine进程
            check_cmd = ["pgrep", "linux-wallpaper"]
            check_result = subprocess.run(check_cmd, capture_output=True, text=True)
    
            if check_result.returncode == 0:
                # 有正在运行的进程，先终止它
                terminate_cmd = ["pkill", "linux-wallpaper"]
                subprocess.run(terminate_cmd, capture_output=True, text=True)
    
            # 启动新的linux-wallpaperengine进程，使用shell=True允许命令重定向
            self.wallpaper_engine_process = subprocess.Popen(
                ' '.join(cmd),  # 将列表转换为字符串
                shell=True,  # 使用shell执行命令，支持nohup和重定向
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
    
            # 将命令写入到脚本文件中，以便系统启动时自动运行
            script_path = os.path.expanduser("~/.config/hypr/Scripts/wallpaper-engine-start.sh")
            # 确保目录存在
            os.makedirs(os.path.dirname(script_path), exist_ok=True)
            
            # 写入脚本内容
            with open(script_path, 'w') as f:
                f.write("#!/bin/bash\n")
                f.write("# 终止已有的linux-wallpaper进程\n")
                f.write("pkill linux-wallpaper 2>/dev/null\n")
                f.write("# 启动新的壁纸引擎进程\n")
                f.write(f"nohup linux-wallpaperengine '{wallpaper_path}' --screen-root eDP-1 --scaling fill &>/dev/null &\n")
            
            # 设置脚本为可执行权限
            os.chmod(script_path, 0o755)
            
            print(f"壁纸已应用，命令已写入 {script_path}")
    
        except Exception as e:
            QMessageBox.critical(self, "错误", f"执行命令时出错:\n{str(e)}")

    def resizeEvent(self, event):
        """窗口大小改变时重新布局"""
        super().resizeEvent(event)
        # 延迟重新布局以避免频繁刷新
        from PyQt5.QtCore import QTimer
        QTimer.singleShot(100, self.display_wallpapers)

    # 添加窗口关闭事件处理方法
    def on_close(self, event):
        """窗口关闭时清理资源"""
        # 接受关闭事件
        event.accept()


def main():
    app = QApplication(sys.argv)

    # 设置应用程序信息
    app.setApplicationName("Wallpaper Engine")
    app.setApplicationVersion("1.0")

    window = WallpaperEngine()
    window.show()

    sys.exit(app.exec_())


if __name__ == "__main__":
    main()