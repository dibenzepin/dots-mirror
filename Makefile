.PHONY: update switch all
.RECIPEPREFIX := $(.RECIPEPREFIX) 

all: update switch
 @echo "done"

update:
 nix flake update
 @echo "updated, now rebuild"

switch:
 home-manager switch --flake .
 @echo "done rebuilding"

