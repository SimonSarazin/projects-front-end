// Add marked to pages
var marked = document.createElement('script');

marked.type = "text/javascript";
marked.src = "http://multibao.meteor.com/integration/marked.min.js";
document.body.appendChild(marked);

jsonp( 'https://api.github.com/repos/monjob/contributions/contents/contributions/{contribution}?{callback}', function(response) {
  var content = response.data.content.replace(/\s/g, '');

  document.querySelector('#multibao').innerHTML = marked(decodeURIComponent(escape(atob(content))));
});

function jsonp( url, callback ) {
  var id = ('jsonp' + Math.random() * new Date() ).replace('.', ''),
      contribution = document.querySelector('#multibao').title,
      script = document.createElement('script');

  url = url.replace('{contribution}', contribution + '.md');
  url = url.replace('{callback}', 'callback=' + id);
  script.src = url;

  document.body.appendChild(script);
  window[id] = function(data) {
    if (callback) {
      callback( data );
    }
  };
}
