#include <gtk/gtk.h>
#include <gtk-layer-shell/gtk-layer-shell.h>
#include <stdio.h>

// 确认对话框回调函数
void on_confirm_dialog_response(GtkDialog *dialog, gint response_id, gpointer user_data) {
    if (response_id == GTK_RESPONSE_YES) {
        g_print("confirmed\n");  // 用户确认操作
    } else {
        g_print("cancelled\n");  // 用户取消操作
    }
    fflush(stdout);
    
    gtk_widget_destroy(GTK_WIDGET(dialog));  // 销毁对话框
    gtk_main_quit();  // 退出主循环
}

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);
    
    // 创建对话框（无父窗口）
    GtkWidget *dialog = gtk_dialog_new_with_buttons(
        "确认操作",
        NULL,  // 无父窗口
        GTK_DIALOG_MODAL,
        "_取消", GTK_RESPONSE_NO,
        "_确定", GTK_RESPONSE_YES,
        NULL
    );
    
    // 设置对话框属性
    gtk_window_set_default_size(GTK_WINDOW(dialog), 120, 80);  // 大小
    gtk_window_set_decorated(GTK_WINDOW(dialog), FALSE);  // 禁用窗口装饰
    
    // 应用 GTK Layer Shell 设置
    gtk_layer_init_for_window(GTK_WINDOW(dialog));
    gtk_layer_set_layer(GTK_WINDOW(dialog), GTK_LAYER_SHELL_LAYER_TOP);
    gtk_layer_set_margin(GTK_WINDOW(dialog), GTK_LAYER_SHELL_EDGE_TOP, 0);
    gtk_layer_set_margin(GTK_WINDOW(dialog), GTK_LAYER_SHELL_EDGE_BOTTOM, 0);
    gtk_layer_set_margin(GTK_WINDOW(dialog), GTK_LAYER_SHELL_EDGE_LEFT, 0);
    gtk_layer_set_margin(GTK_WINDOW(dialog), GTK_LAYER_SHELL_EDGE_RIGHT, 0);
    gtk_layer_set_keyboard_mode(GTK_WINDOW(dialog), GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);
    gtk_layer_set_namespace(GTK_WINDOW(dialog), "confirm-dialog");
    
    // 创建内容区域
    GtkWidget *content_area = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
    gtk_container_set_border_width(GTK_CONTAINER(content_area), 20);
    
    // 创建主布局
    GtkWidget *vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 15);
    gtk_container_add(GTK_CONTAINER(content_area), vbox);
    
    // 添加图标
    GtkWidget *icon = gtk_image_new_from_icon_name("dialog-question", GTK_ICON_SIZE_DIALOG);
    gtk_widget_set_halign(icon, GTK_ALIGN_CENTER);
    
    // 添加标题
    GtkWidget *title_label = gtk_label_new(NULL);
    gtk_label_set_markup(GTK_LABEL(title_label), "<span size='large' weight='bold'>确认操作</span>");
    gtk_widget_set_halign(title_label, GTK_ALIGN_CENTER);
    
    // 添加消息
    GtkWidget *message_label = gtk_label_new(NULL);
    gtk_label_set_markup(GTK_LABEL(message_label), 
        "您确定要执行此操作吗？\n"
        "<span size='small' foreground='#6c7086'>执行后会返回SDDM界面，并关闭当前所有应用进程</span>");
    gtk_label_set_line_wrap(GTK_LABEL(message_label), TRUE);
    gtk_label_set_justify(GTK_LABEL(message_label), GTK_JUSTIFY_CENTER);
    gtk_widget_set_halign(message_label, GTK_ALIGN_CENTER);
    
    // 添加到布局
    gtk_box_pack_start(GTK_BOX(vbox), icon, FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(vbox), title_label, FALSE, FALSE, 0);
    gtk_box_pack_start(GTK_BOX(vbox), message_label, FALSE, FALSE, 0);
    
    // 添加CSS样式 - Wayland/Hyprland深色主题
    GtkCssProvider *provider = gtk_css_provider_new();
    gtk_css_provider_load_from_data(provider, 
        "window {"
        "   background: #1e1e2e;"
        "   border-radius: 12px;"
        "   border: 1px solid #313244;"
        "   box-shadow: 0 5px 15px rgba(0,0,0,0.5);"
        "}"
        "label {"
        "   color: #cdd6f4;"
        "}"
        "button {"
        "   padding: 8px 16px;"
        "   border-radius: 6px;"
        "   font-weight: bold;"
        "   border: none;"
        "   background: #313244;"
        "   color: #cdd6f4;"
        "   transition: all 0.2s ease;"
        "}"
        "button:hover {"
        "   background: #45475a;"
        "   box-shadow: 0 0 5px rgba(0,0,0,0.3);"
        "}"
        "button:nth-child(2) {"
        "   background: #a6e3a1;"
        "   color: #1e1e2e;"
        "}"
        "button:nth-child(2):hover {"
        "   background: #94e2d5;"
        "}", -1, NULL);
    
    // 应用样式
    GtkStyleContext *context = gtk_widget_get_style_context(dialog);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), 
                                  GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    
    // 连接响应信号
    g_signal_connect(dialog, "response", G_CALLBACK(on_confirm_dialog_response), NULL);
    
    // 显示并运行
    gtk_widget_show_all(dialog);
    gtk_main();
    
    return 0;
}
