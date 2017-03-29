###############################################################
#
# Constante a completer pour la remise de votre travail:
#  - CODES_PERMANENTS
#
###############################################################

### Vous devez completer l'une ou l'autre des definitions.   ###

# Deux etudiants:
# Si vous etes deux etudiants: Indiquer vos codes permanents.
CODES_PERMANENTS='ABCD01020304,GHIJ11121314'


# Un etudiant:
# Si vous travaillez seul: Supprimer le diese en debut de ligne et
# indiquer votre code permanent (sans changer le nom de la variable).
#CODES_PERMANENTS='ABCD01020304'

#--------------------------------------------------------

########################################################################
PGM=./ga.rb
########################################################################

.IGNORE:

# Constantes/cibles a modifier selon votre avancement (exemple, test)
# et selon la commande en cours de developpement.

WIP=ajouter
#WIP=motifs

#NIVEAU_TEST=NIVEAU=base ruby
#NIVEAU_TEST=NIVEAU=intermediaire ruby
#NIVEAU_TEST=NIVEAU=avance ruby
NIVEAU_TEST=ruby   # Tous les niveaux!

#wip: wip_ex
wip: wip_test
#wip: test_all # Tous les tests, mais commande par commande.
#wip: tous_les_tests # Tous les tests en une seule et unique execution!

#-------------------
wip_ex: ex_$(WIP)  # ATTENTION: Certaines commandes ont des tests mais pas d'exemples.

wip_test:
	$(NIVEAU_TEST) Tests/$(WIP)_test.rb


##################################
# Cibles pour les exemples d'execution.
##################################
ex ex_all: 
	@echo ""
	make ex_ajouter
	@echo ""
	make ex_lister
	@echo ""
	make ex_lister_format
	@echo ""
	make ex_nb_credits
	@echo ""
	make ex_prealables
	@echo ""
	make ex_supprimer
	@echo ""
	make ex_trouver
	@echo ""
	make ex_trouver_format

ex_ajouter: ex_init
	$(PGM) ajouter INF2160 "Paradigmes de programmation" 3 INF1130 INF2120
	# Il devrait y avoir 5 cours
	$(PGM) lister
	# Il devrait y avoir 6 cours
	echo 'INF600A "Langages de script" 3 INF2160 INF1130' | $(PGM) ajouter
	$(PGM) lister

ex_init:
	@cp -f cours.txt.init .cours.txt

ex_lister: ex_init
	# Il devrait y avoir 4 cours.
	$(PGM) lister

ex_lister_format: ex_init
	$(PGM) lister --format="%S"
	$(PGM) lister --format="%S => '%T'"
	$(PGM) lister --format="%S => '%T' (%C)"
	$(PGM) lister --format="%S => '%-40T' (%C)"

ex_prealables: ex_init
	# Il devrait y avoir deux prealables: INF1130 et INF2120
	$(PGM) prealables INF3105

	# Il devrait y avoir trois prealables: INF1120, INF1130 et INF2120
	$(PGM) prealables --tous INF3105

ex_supprimer: ex_init
	$(PGM) supprimer INF3105
	# Il devrait y avoir 3 cours
	$(PGM) lister
	# Il devrait y avoir 2 cours
	echo "INF1120" | $(PGM) supprimer
	$(PGM) lister

ex_trouver: ex_init
	# Les 4 cours actifs devraient etre affiches
	$(PGM) trouver INF
	# Seul le cours INF3105 devrait etre affiche
	$(PGM) trouver 3105
	# Avec tri selon titre
	$(PGM) trouver --cle_tri=titre .

ex_nb_credits: ex_init
	# Devrait indiquer 6 credits
	$(PGM) nb_credits INF1120 INF2120

ex_trouver_format: ex_init
	# Va affichier les 4 items selon le format indique.
	$(PGM) trouver --format="%S => '%T' [%C cr.]" '.*'


##################################
# Cibles pour les vrais test.
##################################

test_all:
	@echo "++ RESULTATS DES TESTS ++" > resultats.txt
	@#
	@echo "-- ruby Tests/ajouter_test.rb" >> resultats.txt
	ruby Tests/ajouter_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/desactiver_reactiver_test.rb" >> resultats.txt
	ruby Tests/desactiver_reactiver_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/init_test.rb" >> resultats.txt
	ruby Tests/init_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/lister_test.rb" >> resultats.txt
	ruby Tests/lister_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/nb_credits_test.rb" >> resultats.txt
	ruby Tests/nb_credits_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/prealables_test.rb" >> resultats.txt
	ruby Tests/prealables_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/supprimer_test.rb" >> resultats.txt
	ruby Tests/supprimer_test.rb | tee -a resultats.txt
	@#
	@echo "-- ruby Tests/trouver_test.rb" >> resultats.txt
	ruby Tests/trouver_test.rb | tee -a resultats.txt

test_base:
	NIVEAU=base make test_all

test_intermediaire:
	NIVEAU=intermediaire make test_all

test_avance:
	NIVEAU=avance make test_all

tous_les_tests:
	rake test

############################################
# Cibles pour les tests unitaires de Cours et des motifs.
############################################
test_cours:
	ruby Tests/cours_test.rb

test_motifs:
	ruby Tests/motifs_test.rb


##################################
# Nettoyage.
##################################
clean:
	rm -f *~ *.bak
	rm -rf tmp

########################################################################
########################################################################

BOITE=INF600A
remise:
	PWD=$(shell pwd)
	ssh oto.labunix.uqam.ca oto rendre_tp tremblay_gu $(BOITE) $(CODES_PERMANENTS) $(PWD)
	ssh oto.labunix.uqam.ca oto confirmer_remise tremblay_gu $(BOITE) $(CODES_PERMANENTS)

########################################################################
########################################################################
