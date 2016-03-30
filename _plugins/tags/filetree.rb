# Syntax:
# {% filetree %}
# folder/
#   code.java
#   text.txt
#   subfolder/
#     asset.png
#     ...
#   closedfolder/
# {% endfiletree %}
#
# Outputs:
# <ul class="fa-ul">
#   <li>{% icon fa-li fa-folder-open-o %}folder</li>
#   <ul class="fa-ul">
#       <li>{% icon fa-li fa-file-code-o %}code.java</li>
#       <li>{% icon fa-li fa-file-text-o %}text.txt</li>
#       <li>{% icon fa-li fa-folder-open-o %}subfolder</li>
#       <ul class="fa-ul">
#           <li>{% icon fa-li fa-folder-o %}subfolder</li>
#           <li>{% icon fa-li fa-file-image-o %}asset.png</li>
#           <li>{% icon fa-ellipsis-h %}</li>
#       </ul>
#       <li>{% icon fa-li fa-folder-o %}closedfolder</li>
#   </ul>
# </ul>


module Jekyll
  class FiletreeTag < Liquid::Block
    ICON_CODE = "fa-file-code-o"
    ICON_IMAGE = "fa-file-image-o"
    ICON_TEXT = "fa-file-text-o"
    ICON_GENERIC = "fa-file-o"
    @@icon_names = {
      '.gradle' => ICON_CODE,
      '.java' => ICON_CODE,
      '.kt' => ICON_CODE,
      '.txt' => ICON_TEXT,
      '.doc' => ICON_TEXT,
      '.md' => ICON_TEXT,
      '.png' => ICON_IMAGE,
      '.jpg' => ICON_IMAGE,
      '.bmp' => ICON_IMAGE,
      '.gif' => ICON_IMAGE,
    }

    def render(context)
      page = context.environments.first["page"]

      # Prepare input string into input array
      input = super.sub(/\t/, ' ').split(/\r?\n/).reject { |s| s.empty? }
      if input.size == 0
        Log.warn(page, 'Ignoring empty filetree block')
        return ""
      end

      # Calculate and sanity check indents
      lineIndents = Hash.new
      hasChildren = Hash.new
      for line in input
        lineIndents[line] = line.length - line.lstrip.length
        hasChildren[line] = false
      end


      indentLen = 1
      for line in input
        currIndent = lineIndents[line]
        if currIndent > 0
          indentLen = currIndent
          break
        end
      end

      for line in input
        lineIndents[line] /= indentLen
      end

      prevIndent = -1
      lastLine = nil
      for line in input
        nextIndent = lineIndents[line]
        if (prevIndent - nextIndent).abs > 1
          Log.err(page, "Bad filetree indents, got #{prevIndent} then #{nextIndent}. Aborting!")
          return ""
        end

        if (nextIndent > prevIndent and lastLine)
          hasChildren[lastLine] = true
        end

        lastLine = line

        prevIndent = nextIndent
      end

      # Convert input to output
      currIndent = -1
      output = StringIO.new
      for line in input
        nextIndent = lineIndents[line]
        if nextIndent > currIndent
          output << '<ul class="fa-ul">'
          currIndent += 1
        elsif nextIndent < currIndent
          output << '</ul>'
          currIndent -= 1
        end

        lineStrip = line.strip
        ext = File.extname(lineStrip)
        if lineStrip.end_with?('/')
          icon = hasChildren[line] ? 'fa-folder-open-o' : 'fa-folder-o'
          output << "<li>{% icon fa-li #{icon} %}#{line.chomp('/')}</li>"
        elsif lineStrip == "..."
          output << "<li>{% icon fa-ellipsis-h %}</li>"
        elsif !ext.empty?
          icon = @@icon_names[ext]
          if icon.nil?
            Log.warn(page, "Unknown filetype: #{lineStrip}")
            icon = ICON_GENERIC
          end
          output << "<li>{% icon fa-li #{icon} %}#{lineStrip}</li>"
        else
          Log.warn(page, "Skipping unknown input: #{lineStrip}")
        end
      end

      while currIndent > -1
        output << '</ul>'
        currIndent -= 1
      end

      template = Liquid::Template.parse(output.string)
      template.render()
    end

  end
end

Liquid::Template.register_tag('filetree', Jekyll::FiletreeTag)