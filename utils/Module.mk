# Module.mk for utils module
# Copyright (c) 2000 Rene Brun and Fons Rademakers
#
# Author: Fons Rademakers, 29/2/2000

MODDIR       := utils
MODDIRS      := $(MODDIR)/src
MODDIRI      := $(MODDIR)/inc

UTILSDIR     := $(MODDIR)
UTILSDIRS    := $(UTILSDIR)/src
UTILSDIRI    := $(UTILSDIR)/inc

##### rootcint #####
ROOTCINTS    := $(MODDIRS)/rootcint.cxx $(wildcard $(MODDIRS)/R*.cxx)
ROOTCINTO    := $(ROOTCINTS:.cxx=.o)
ROOTCINTDEP  := $(ROOTCINTO:.o=.d)
ROOTCINTTMPO := $(ROOTCINTS:.cxx=_tmp.o)
ROOTCINTTMPEXE:= $(MODDIRS)/rootcint_tmp$(EXEEXT)
ROOTCINTEXE  := bin/rootcint$(EXEEXT)

##### rlibmap #####
RLIBMAPS     := $(MODDIRS)/rlibmap.cxx
RLIBMAPO     := $(RLIBMAPS:.cxx=.o)
RLIBMAPDEP   := $(RLIBMAPO:.o=.d)
RLIBMAP      := bin/rlibmap$(EXEEXT)

# include all dependency files
INCLUDEFILES += $(ROOTCINTDEP) $(RLIBMAPDEP)

##### local rules #####
$(ROOTCINTEXE): $(CINTLIB) $(ROOTCINTO) $(METAUTILSO) $(MAKEINFO) $(IOSENUM) $(PCHEXTRAOBJ)
		$(LD) $(LDFLAGS) -o $@ $(ROOTCINTO) $(METAUTILSO) \
		   $(RPATH) $(CINTLIBS) $(CILIBS)

$(ROOTCINTTMPEXE): $(CINTTMPO) $(ROOTCINTTMPO) $(METAUTILSO) $(MAKEINFO) $(IOSENUM) $(PCHEXTRAOBJ)
		$(LD) $(LDFLAGS) -o $@ \
		   $(ROOTCINTTMPO) $(METAUTILSO) $(CINTTMPO) $(CILIBS)

$(RLIBMAP):     $(RLIBMAPO)
ifneq ($(PLATFORM),win32)
		$(LD) $(LDFLAGS) -o $@ $<
else
		$(LD) $(LDFLAGS) -o $@ $< imagehlp.lib
endif

all-utils:      $(ROOTCINTTMPEXE) $(ROOTCINTEXE) $(RLIBMAP)

clean-utils:
		@rm -f $(ROOTCINTTMPO) $(ROOTCINTO) $(RLIBMAPO)

clean::         clean-utils

distclean-utils: clean-utils
		@rm -f $(ROOTCINTDEP) $(ROOTCINTTMPEXE) $(ROOTCINTEXE) \
		   $(RLIBMAPDEP) $(RLIBMAP) \
		   $(UTILSDIRS)/*.exp $(UTILSDIRS)/*.lib

distclean::     distclean-utils

##### extra rules ######
$(UTILSDIRS)%_tmp.o: $(UTILSDIRS)%.cxx
	$(CXX) $(OPT) $(CXXFLAGSNOPCH) -UHAVE_CONFIG -DROOTBUILD -c $< $(CXXOUT)$@
