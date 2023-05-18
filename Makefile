all:
	zip -9 -r dist/game.love . -x \*dist\*
	love.js dist/game.love dist/2023-spring-game-jam -c -t "2023 Spring Game Jam"
	cp -r dist/2023-spring-game-jam ~/dev/mikepurdy.dev/static/
	
