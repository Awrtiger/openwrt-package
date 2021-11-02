local jd = 'jd-dailybonus'
local uci = luci.model.uci.cursor()
local sys = require 'luci.sys'

m = Map(jd)
-- [[ 基本设置 ]]--

s = m:section(TypedSection, 'global', translate('基本设置'))
s.anonymous = true

o = s:option(DynamicList, "Cookies", translate("账号 Cookie 列表"))
o.rmempty = false
o.description = translate('双击输入框可调出二维码，扫码后自动填入。')

o = s:option(DummyValue, '', '')
o.rawhtml = true
o.template = 'jd-dailybonus/cookie_tools'

o = s:option(DynamicList, "jrBody", translate('金融 POST Body'))
o.rmempty = false
o.default = ''
o.description = translate('京东金融签到 POST Body（以reqData=开头），与上方的Cookies列表一一对应，没有可不填（可能导致京东金融签到失败）')

o = s:option(Value, 'stop', translate('延迟签到'))
o.rmempty = false
o.default = 0
o.datatype = integer
o.description = translate('自定义延迟签到,单位毫秒. 默认分批并发无延迟. (延迟作用于每个签到接口, 如填入延迟则切换顺序签到. ) ')

o = s:option(Value, 'out', translate('接口超时'))
o.rmempty = false
o.default = 0
o.datatype = integer
o.description = translate('接口超时退出,单位毫秒 用于可能发生的网络不稳定, 0则关闭.')

-- server chan
o = s:option(ListValue, 'serverurl', translate('Server酱的推送接口地址'))
o:value('scu', translate('SCU'))
o:value('sct', translate('SCT'))
o.default = 'scu'
o.rmempty = false
o.description = translate('选择Server酱的推送接口')

o = s:option(Value, 'serverchan', translate('Server酱 SCKEY'))
o.rmempty = true
o.description = translate('微信推送，基于Server酱服务，请自行登录 http://sc.ftqq.com/ 绑定并获取 SCKEY。')

-- Bark
o = s:option(Value, 'bark_token', translate('Bark Token'))
o.rmempty = true
o.description = translate('Bark Token')

o = s:option(Value, 'bark_srv', translate('Bark 服务器地址'))
o.rmempty = true
o.default = "https://api.day.app"
o.description = translate('如https://your.domain:port 具体自建服务器设定参见：https://github.com/Finb/Bark')

o = s:option(Flag, 'bark_isA', translate('Bark 保存到记录'))
o.default = 1
o.rmempty = true

o = s:option(Value, 'bark_group', translate('Bark 分组标识'))
o.default = "京东每日签到"
o.rmempty = true
o:depends('bark_isA', '1')

o = s:option(Value, 'bark_sound', translate('Bark 通知声音'))
o.rmempty = true
o.default = "silence.caf"
o.description = translate('如silence.caf 具体设定参见：https://github.com/Finb/Bark/tree/master/Sounds')

o = s:option(Value, 'bark_icon', translate('Bark 通知图标'))
o.rmempty = true
o.default = "http://day.app/assets/images/avatar.jpg"
o.description = translate('(仅 iOS15 或以上支持) 如http://day.app/assets/images/avatar.jpg 具体设定参见：https://github.com/Finb/Bark#%E5%85%B6%E4%BB%96%E5%8F%82%E6%95%B0')

o = s:option(Value, 'bark_level', translate('Bark 时效性通知'))
o.rmempty = true
o.default = "active"
o.description = translate('可选参数值：active：不设置时的默认值，系统会立即亮屏显示通知。timeSensitive：时效性通知，可在专注状态下显示通知。passive：仅将通知添加到通知列表，不会亮屏提醒。')

--Auto Run Script Service

o = s:option(Flag, 'auto_run', translate('自动签到'))
o.rmempty = false

o = s:option(ListValue, 'auto_run_time_h', translate('每天签到时间(小时)'))
for t = 0, 23 do
    o:value(t, t)
end
o.default = 1
o.rmempty = true
o:depends('auto_run', '1')
o = s:option(ListValue, 'auto_run_time_m', translate('每天签到时间(分钟)'))
for t = 0, 59 do
    o:value(t, t)
end
o.default = 1
o.rmempty = true
o:depends('auto_run', '1')

-- Auto Update Script Service

o = s:option(Flag, 'auto_update', translate('自动更新'))
o.rmempty = false

o = s:option(ListValue, 'auto_update_time', translate('每天更新时间'))
for t = 0, 23 do
    o:value(t, t .. ':01')
end
o.default = 1
o.rmempty = true
o:depends('auto_update', '1')

o = s:option(Value, 'remote_url', translate('更新源地址'))
o:value('https://raw.githubusercontent.com/NobyDa/Script/master/JD-DailyBonus/JD_DailyBonus.js', translate('GitHub'))
o:value('https://raw.sevencdn.com/NobyDa/Script/master/JD-DailyBonus/JD_DailyBonus.js', translate('GitHub CDN 01'))
o:value('https://cdn.jsdelivr.net/gh/NobyDa/Script/JD-DailyBonus/JD_DailyBonus.js', translate('GitHub CDN 02'))
o:value('https://ghproxy.com/https://raw.githubusercontent.com/NobyDa/Script/master/JD-DailyBonus/JD_DailyBonus.js', translate('韩国首尔'))
o.default = 'nil'
o.rmempty = false
o.description = translate('当GitHub源无法更新时,可以选择使用国内Gitee源,GitHub CDN可能比原地址更晚更新，但速度快')

o = s:option(DummyValue, '', '')
o.rawhtml = true
o.version = sys.exec('uci get jd-dailybonus.@global[0].version')
o.template = 'jd-dailybonus/update_service'

return m
