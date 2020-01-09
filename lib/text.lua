local text_util = {}

function text_util.font(font, content)
    return {
        "blueprint-editor-formatting.font",
        font,
        content,
    }
end

function text_util.color(r, g, b, content)
    return {
        "blueprint-editor-formatting.color",
        r .. "," .. g .. "," .. b,
        content,
    }
end

function text_util.bold(content)
    return text_util.font("default-bold", content)
end

function text_util.two_lines(line1, line2)
    return {
        "blueprint-editor-formatting.two-lines",
        line1,
        line2,
    }
end

function text_util.icon_text(icon_type, icon_name, content)
    return {
        "blueprint-editor-formatting.icon-with-text",
        icon_type,
        icon_name,
        content,
    }
end

function text_util.cwhite(content)
    return {
        "blueprint-editor-formatting.color-white",
        content,
    }
end

function text_util.ctooltip(content)
    return {
        "blueprint-editor-formatting.color-tooltip",
        content,
    }
end

function text_util.cmousebutton(content)
    return {
        "blueprint-editor-formatting.color-mousebutton",
        content,
    }
end

return text_util