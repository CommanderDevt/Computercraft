CML - basically just html but written from scratch with less stuff for my computercraft project
it follows the same tag structure like html (<b>text</b>)

Notice: [[
everything related to color uses the CCC Format
"CCC" is an acronym for "Computer Craft Color"
learn more about CCC on https://tweaked.cc/module/colors.html
]]

Tags:
<t~>[TEXT]</t~> -- will show [TEXT]
<config~></config~>
Attributes:
x = [NUMBER] - The X position where the text starts writing
y = [NUMBER] - The Y position where the text starts writing
color = [STRING] - will set the text color of the text to the CCC provided
bgcolor = [STRING] - will set the background color of the text to the CCC provided
link = [STRING] - will take you to the specified website
Settings:
Title = [STRING] - The website's Title
Icon = [STRING] - The website's icon. Can be only a single character long
Bgcolor = [STRING] - The website's background color to the CCC provided (1 character max)
Default_textbgcolor = [STRING] - The default text background color in CCC (1 character max)
Default_textcolor = [STRING] - The default text color in CCC (1 character max)

you can modify settings using the "config" tag, set the config tag's attributes to the Settings to update it, heres an example:
<config~Title=haii,Bgcolor=0></config~>
