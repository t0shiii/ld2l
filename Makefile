
LESSC := lessc
UGLIFYJS := uglifyjs
SHOWDOWN := showdown
ECHO := @echo -e

JSFLAGS := -m -c -r "$$,_"
LESSFLAGS := --plugin=less-plugin-clean-css
MDFLAGS := --parseImgDimensions --simplifiedAutoLink --excludeTrailingPunctuationFromURLs
MDFLAGS += --strikethrough --tables --tasklists --simpleLineBreaks --emoji

CLIENTDIR := $(shell pwd)/client
STATICDIR := $(shell pwd)/static

RED := \e[91m
GREEN := \e[92m
BLUE := \e[94m
NONE := \e[0m

JSSRC := $(wildcard $(CLIENTDIR)/javascript/*.js)
JSOBJ := $(subst $(CLIENTDIR),$(STATICDIR),$(JSSRC))

CSSSRC := $(wildcard $(CLIENTDIR)/css/*.less)
CSSOBJ := $(subst $(CLIENTDIR),$(STATICDIR),$(patsubst %.less,%.css,$(CSSSRC)))

# $1 = src file list to build
# $2 = obj file list to build
# $3 = build function
define CALL_FOREACH
WORDS := $$(shell seq $$(words $1))
$$(foreach idx,$$(WORDS),$$(eval $$(call $3,$$(word $$(idx),$1),$$(word $$(idx),$2))))
endef

define BUILD_JS

$2 : $1
	$(ECHO) "$(RED)[ JS ]$(NONE) $$(notdir $1)"
	@$(UGLIFYJS) $(JSFLAGS) $1 -o $2

endef

define BUILD_CSS
$2 : $1
	$(ECHO) "$(BLUE)[LESS]$(NONE) $$(notdir $1)"
	@$(LESSC) $(LESSFLAGS) $1 > $2

endef

define BUILD_MD
$2 : $1
	$(ECHO) "$(GREEN)[ MD ]$(NONE) $$(notdir $1)"
	@$(SHOWDOWN) makehtml $(MDFLAGS) -i $1 -o $2

endef

all : $(JSOBJ) $(CSSOBJ) $(MDOBJ)

clean :
	rm -rf $(JSOBJ) $(CSSOBJ) $(MDOBJ)

$(eval $(call CALL_FOREACH,$(JSSRC),$(JSOBJ),BUILD_JS))
$(eval $(call CALL_FOREACH,$(CSSSRC),$(CSSOBJ),BUILD_CSS))
$(eval $(call CALL_FOREACH,$(MDSRC),$(MDOBJ),BUILD_MD))
