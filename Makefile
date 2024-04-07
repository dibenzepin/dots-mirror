.PHONY: update switch all
.RECIPEPREFIX := $(.RECIPEPREFIX) 

switch:
 home-manager switch --flake .
 @echo "done rebuilding"

all: update switch
 @echo "done"

update:
 nix flake update
 @echo "updated, now rebuild"

