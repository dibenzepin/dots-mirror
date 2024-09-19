.PHONY: update switch all
.RECIPEPREFIX := $(.RECIPEPREFIX) 

error:
 @echo "please use one of the targets: update, switch, init"
  
init:
 nix run home-manager/master -- switch --flake .
 @echo "done"

update:
 nix flake update
 @echo "updated, you may now rebuild"
 
switch:
 home-manager switch --flake .
 @echo "done rebuilding"

news:
 home-manager news --flake .
 
