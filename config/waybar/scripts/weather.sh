#!/bin/sh

# 1. 通过 IP 获取当前位置的经纬度（使用 ipinfo.io，无需 API Key）
GEO_DATA=$(curl -s https://ipinfo.io/json)

# 检查是否成功获取地理位置
if [ -z "$GEO_DATA" ] || echo "$GEO_DATA" | grep -q "error"; then
    printf '{"text": "📍❓", "tooltip": "Failed to get location"}\n'
    exit 0
fi

# 提取经纬度（格式为 "lat,lon"）
COORDS=$(echo "$GEO_DATA" | jq -r '.loc')
CITY=$(echo "$GEO_DATA" | jq -r '.city // "Unknown"')

# 如果没有坐标，返回错误
if [ "$COORDS" = "null" ] || [ -z "$COORDS" ]; then
    printf '{"text": "📍❓", "tooltip": "Location unavailable"}\n'
    exit 0
fi

LAT=$(echo "$COORDS" | cut -d',' -f1)
LON=$(echo "$COORDS" | cut -d',' -f2)

# 2. 调用 Open-Meteo 获取天气
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m,weather_code"
WEATHER_DATA=$(curl -s "$URL")

# 检查天气数据是否有效
if echo "$WEATHER_DATA" | jq -e '.error // false' > /dev/null; then
    printf '{"text": "🌦️❌", "tooltip": "Weather API error"}\n'
    exit 0
fi

TEMP=$(echo "$WEATHER_DATA" | jq -r '.current.temperature_2m // "N/A"')
WMO_CODE=$(echo "$WEATHER_DATA" | jq -r '.current.weather_code // -1')

# 3. 根据 WMO 天气代码设置图标
case $WMO_CODE in
    0) ICON="☀️" ;;               # Clear sky
    1|2|3) ICON="⛅" ;;           # Mainly clear / Partly cloudy / Overcast
    45|48) ICON="🌫️" ;;          # Fog
    51|53|55) ICON="🌧️" ;;       # Drizzle
    56|57) ICON="🌧️" ;;          # Freezing drizzle
    61|63|65) ICON="🌦️" ;;       # Rain
    66|67) ICON="🌧️❄️" ;;        # Freezing rain
    71|73|75|77) ICON="❄️" ;;    # Snow
    80|81|82) ICON="🌧️" ;;       # Rain showers
    85|86) ICON="🌨️" ;;          # Snow showers
    95|96|99) ICON="⛈️" ;;       # Thunderstorm
    *) ICON="☁️" ;;
esac

# 4. 构造输出（Waybar 需要合法 JSON 行）
printf '{"text": "%s %s°C", "tooltip": "📍 %s\\n🌡️ %s°C\\nCode: %s"}\n' \
    "$ICON" "$TEMP" "$CITY" "$TEMP" "$WMO_CODE"
