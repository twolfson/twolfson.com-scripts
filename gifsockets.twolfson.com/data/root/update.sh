npm install -g phantomjs-pixel-server@latest
npm install -g gifsockets-server@latest

forever restart "$(which phantomjs-pixel-server)"
forever restart "$(which gifsockets-server)"
