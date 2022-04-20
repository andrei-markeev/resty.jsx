local type = type
local pairs = pairs
local ipairs = ipairs
local ffi = require "ffi"
local ffi_C = ffi.C
local ffi_new = ffi.new
local ffi_string = ffi.string
local ffi_copy = ffi.copy
local unsigned_char = ffi.typeof "unsigned char[?]"
local uintptr_t = ffi.typeof "uintptr_t"
local str_buf1, str_buf2

ffi.cdef[[
uintptr_t ngx_escape_html(unsigned char *dst, unsigned char *src, size_t size)
]]

local function get_string_buf(size, second)
    if size > 2048 then
        return ffi_new(unsigned_char, size)
    end

    if second then
        if not str_buf2 then
            str_buf2 = ffi_new(unsigned_char, 2048)
        end
        return str_buf2
    else
        if not str_buf1 then
            str_buf1 = ffi_new(unsigned_char, 2048)
        end
        return str_buf1
    end
end
local function escapeHtml(unsafe_html)
    local unsafe_len = #unsafe_html;
    local c_str = get_string_buf(unsafe_len+1)
    ffi_copy(c_str, unsafe_html, unsafe_len+1)

    local addSize = ffi_new(uintptr_t)
    addSize = ffi_C.ngx_escape_html(nil, c_str, unsafe_len)
    if (addSize == 0) then
        return unsafe_html
    end

    local c_str_escaped = get_string_buf(unsafe_len+addSize, true)
    ffi_C.ngx_escape_html(c_str_escaped, c_str, unsafe_len)
    return ffi_string(c_str_escaped, unsafe_len+addSize);
end

local function escapeHtmlAttribute(unsafe)
    if unsafe == true then
        return ""
    elseif unsafe == nil or type(unsafe) == "number" then
        return unsafe
    else
        return escapeHtml(unsafe)
    end
end
local function mapPropsToAttributes(props)
    if (props == nil) then
        return ""
    end
    local html = ""
    for k,v in pairs(props) do
        if v ~= false then
            html = html .. " " .. k .. "=\"" .. escapeHtmlAttribute(v) .. "\""
        end
    end
    return html
end
local function processChild(child)
    if type(child) == "number" then
        return tostring(child)
    elseif type(child) == "string" then
        return escapeHtml(child)
    elseif child.html ~= nil then
        return child.html
    else
        local html = ""
        for i,v in ipairs(child) do
            html = html .. processChild(v)
        end
        return html
    end
end
local function createElement(self, tag, props, ...)
    if type(tag) == "string" then
        local innerHTML = ""
        for i,v in ipairs({...}) do
            innerHTML = innerHTML .. processChild(v)
        end
        return { html = "<" .. tag .. mapPropsToAttributes(props) .. ">" .. innerHTML .. "</" .. tag .. ">" }
    else
        return tag(nil, props, ...)
    end
end

return {
    createElement = createElement
}