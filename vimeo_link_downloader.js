#!/usr/bin/env node

let Vimeo = require('vimeo').Vimeo;
let client = new Vimeo("1592e1ea553f98ec81946ea2e14292ea42f1f77e", "fJjncOcHv5PtmvJJMqFFBgtq82crZB+UR9jla3Wj1YHL+Ucjw5BXvXMgrq4qEB08x1zHdoPmOiqiN9ILSz2wHQFnQgsmNKivaDuKfb1LzM0mpaBEBXcZgzpRCVtOkNWC", "bead71eb803fe422de031fdaee4c47ba");

client.request({
  method: 'GET',
  path: '/users/124701555/videos',
  query: {
    page: 2,
    per_page: 100,
    fields: 'name, uri' 
  }
}, function (error, body, status_code, headers) {
  if (error) {
    console.log('error');
    console.log(error);
  } else {
    console.log('body');
    console.log(body);
  }

  console.log('status code');
  console.log(status_code);
  console.log('headers');
  console.log(headers);
});