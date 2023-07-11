Span = function(el)
  fore_colour = el.attributes['foreground']
  back_colour = el.attributes['background']
  
  -- if no colours specified, return unchange
  if fore_colour == nil and back_colour == nil then return el end

  -- transform to <span style="..."></span>
  if FORMAT:match 'html' then
    style_str = ""
  
    -- remove color attributes
    el.attributes['foreground'] = nil
    el.attributes['background'] = nil
    
    if fore_colour ~= nil then
      style_str = style_str .. 'color:' .. fore_colour .. ';'
    end
    
    if back_colour ~= nil then
      style_str = style_str .. 'background-color:' .. back_colour .. ';'
    end
    
    -- use style attribute instead
    el.attributes['style'] = style_str
    
    -- return full span element
    return el
  else
    -- for other format return unchanged
    return el
  end
end
