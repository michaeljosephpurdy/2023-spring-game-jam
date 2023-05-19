all:
	rm -rf makelove-build
	makelove

serve:
	$(MAKE) all
	unzip -o "makelove-build/lovejs/2023-spring-game-jam-lovejs" -d makelove-build/html/
	echo "http://localhost:8000/makelove-build/html/2023-spring-game-jam/"
	python3 -m http.server

publish:
	$(MAKE) all
	unzip -o "makelove-build/lovejs/2023-spring-game-jam-lovejs" -d ~/dev/mikepurdy.dev/static/ 
