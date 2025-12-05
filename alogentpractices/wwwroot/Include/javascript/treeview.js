function flip(l)
{
	if (document.getElementById)
	{
		var on = (document.getElementById(l).style.display == 'none') ? 1 : 0;
		document.getElementById(l).style.display = (on) ? 'block' : 'none';
		document.images['i'+l].src = (on) ? 'Content/Images/Nav/minus.gif' : 'Content/Images/Nav/plus.gif';
	}
}
