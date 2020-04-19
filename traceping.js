// Extract target for traceping from current path
function getURLParameter(name) {
    return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
    );
}

// Add traceping output
function init () {
    var target = getURLParameter('target');
    if ( target
      && target.substring(0,1) != '_' // does not begin with a _
      && target.indexOf('.') != -1  // contains a . in it
    ) {
      // Add traceping to current host view
      traceping_div = document.createElement('div');
      traceping_div.id = 'traceping';
      traceping_div.class = 'panel-body';
      // Only add traceping to current result
      item = document.querySelectorAll('div.imgCrop_wrap').item(0);
       if (item != null) {
          item.parentElement.parentElement.appendChild(traceping_div);
          fetch('/traceping.fcgi?target=' + target).then(data => data.text()).then(html => document.getElementById('traceping').innerHTML = html);
      }
    }
}

// Load traceping output once everything is load"d
var everythingLoaded = setInterval(function() {
  if (/loaded|complete/.test(document.readyState)) {
    clearInterval(everythingLoaded);
    init(); // this is the function that gets called when everything is loaded
  }
}, 10);
