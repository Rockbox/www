if (document.styleSheets[1].cssRules) {
    var secondStyle = document.styleSheets[1].cssRules[0].style;
    var fontStyle = document.styleSheets[1].cssRules[2].style;
    var joinStyle = document.styleSheets[1].cssRules[3].style;
}
else if (document.styleSheets[1].rules) {
    var secondStyle = document.styleSheets[1].rules[0].style;
    var fontStyle = document.styleSheets[1].rules[2].style;
    var joinStyle = document.styleSheets[1].rules[3].style;
}

var autoscroll = false;

function getCookie(name) {
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1) {
        begin = dc.indexOf(prefix);
        if (begin != 0) return null;
    } else {
        begin += 2;
    }
    var end = document.cookie.indexOf(";", begin);
    if (end == -1) {
        end = dc.length;
    }
    return unescape(dc.substring(begin + prefix.length, end));
}

function _(id) {
    return document.getElementById(id);
}

function seconds(show)
{
    if (show==1)
        secondStyle.display = 'inline';
    else
        secondStyle.display = 'none';
    save_settings();
}

function joins(show)
{
    if (show==1)
        joinStyle.display = 'table-row';
    else
        joinStyle.display = 'none';
    save_settings();
}

function font(family)
{
    fontStyle.fontFamily = family;
    save_settings();
}

function fontsize(size)
{
    fontStyle.fontSize = size;
    save_settings();
}

function save_settings()
{
    var date = new Date();
    date.setTime(date.getTime()+(900*86400*1000));
    var expires = "; expires="+date.toGMTString();
    var end = ";";

    document.cookie = "font=" +
        fontStyle.fontFamily + expires + end;

    document.cookie = "fontsize=" +
        fontStyle.fontSize + expires + end;

    if (secondStyle.display == 'inline')
        document.cookie = "showseconds=1" + expires + end;
    else
        document.cookie = "showseconds=0" + expires + end;

    if (joinStyle.display == 'table-row')
        document.cookie = "showjoins=1" + expires + end;
    else
        document.cookie = "showjoins=0" + expires + end;
}

function reader_init()
{
    var tmp = getCookie('font');
    if (tmp && tmp != '')
        fontStyle.fontFamily = tmp;

    tmp = getCookie('fontsize');
    if (tmp && tmp != "")
        fontStyle.fontSize = tmp;

    tmp = getCookie('showseconds');
    if (tmp == '1')
        secondStyle.display = 'inline';
    else
        secondStyle.display = 'none';

    tmp = getCookie('showjoins');
    if (tmp == '1')
        joinStyle.display = 'table-row';
    else
        joinStyle.display = 'none';
}

function scroll_to_bottom()
{
    if (autoscroll != false)
        window.scrollTo(0,50000);
}

function findClass(className)
{
    var needle = '.'+className;

    for (var s = 0; s < document.styleSheets.length; s++)
    {
        if(document.styleSheets[s].rules)
        {
            for (var r = 0; r < document.styleSheets[s].rules.length; r++)
            {
                if (document.styleSheets[s].rules[r].selectorText == needle)
                {
                    return document.styleSheets[s].rules[r];
                }
            }
        }
        else if(document.styleSheets[s].cssRules)
        {
            for (var r = 0; r < document.styleSheets[s].cssRules.length; r++)
            {
                if (document.styleSheets[s].cssRules[r].selectorText == needle)
                    return document.styleSheets[s].cssRules[r];
            }
        }
    }

    return null;
}

var markedClass = null;

function markNick(nick)
{
    var newClass = findClass("row"+nick);

    // clear previous mark
    if (markedClass)
        markedClass.style.backgroundColor = "white";

    // if same name, don't set new mark
    if (newClass == markedClass) {
        markedClass = null;
        return;
    }

    // set new mark
    if (newClass)
        newClass.style.backgroundColor = "yellow";
    markedClass = newClass;
}


reader_init();
