var target = new Date(); /* Target date will be set in countdown_refresh() */
var start  = new Date(); /* Keep the page's load date as reference */
var tmo; /* timeout object */

function set_text( id, val )
{
    if( document.getElementById )
    {
        var elt = document.getElementById( id );
        while( elt.hasChildNodes() )
            elt.removeChild( elt.firstChild );
        elt.appendChild( document.createTextNode( val ) );
    }
    else
    {
        /* IE 4 sucks */
        var elt = document.all[id];
        elt.innerHTML = val;
    }
}

function padd( value )
{
    if( value < 10 ) return '0'+value;
    else return value;
}

function countdown_update()
{
    var now = new Date();
    var diff = (target.getTime() - now.getTime())/1000;

    /* Time's out! Build must be done */
    if( diff < 0 )
    {
        var diff2 = (now.getTime() - start.getTime())/1000;

        /* Don't reload less than 30 secs after loading the page */
        if( diff2 > 30 )
        {
            clearTimeout(tmo); /* avoid reload loop */
            window.location.reload();
        }
    }

    var secs = Math.floor( diff % 60 );
    var mins = Math.floor( diff / 60 );
    if( mins < 0 ) mins++; /* We want to round towards 0 */
    if( secs < 0 ) secs++; /* Same here */

    var text = '';
    if( diff < 0 )
    {
        /* Looks like we messed up in the ETA */
        text += 'should have been done ' + -mins + 'm ' + -secs + 's ago';
    }
    else
    {
        text += 'expected to complete in ' + mins + 'm ' + secs + 's';
    }
    //text += ' ( target: ' + target.toString()
    //      + ' / now: ' + now.toString() + ')';
    text += ', at ' + padd(target.getHours())
             + ':' + padd(target.getMinutes())
             + ':' + padd(target.getSeconds());
    set_text( 'countdown_text', text );
}

function countdown_refresh_loop()
{
    /* run countdown_update() every 1 second */
    tmo = setTimeout( 'countdown_refresh_loop()', 1000 );
    countdown_update();
}

function countdown_refresh( year, month, day, hour, min, sec )
{
    /* initialize target date. Inputs are expected to be UTC */
    target.setUTCFullYear( year );
    target.setUTCMonth( month );
    target.setUTCDate( day );
    target.setUTCHours( hour );
    target.setUTCMinutes( min );
    target.setUTCSeconds( sec );

    /* launch refresh loop */
    tmo = setTimeout( 'countdown_refresh_loop()', 1 );
}

function toggle_table()
{
    var bigtable = document.getElementById("bigtable");
    var smalltable = document.getElementById("smalltable");

    if (bigtable.style.display == "none") {
        bigtable.style.display = "block";
        smalltable.style.display = "none";
    } else {
        bigtable.style.display = "none";
        smalltable.style.display = "block";
    }
}

function toggle_sizetable()
{
    var ramtable = document.getElementById("ramtable");
    var bintable = document.getElementById("bintable");

    if (ramtable.style.display == "none") {
        ramtable.style.display = "block";
        bintable.style.display = "none";
    } else {
        ramtable.style.display = "none";
        bintable.style.display = "block";
    }
}
