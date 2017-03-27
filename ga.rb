#!/usr/bin/env ruby

#
# Gestion de cours et de programme d'etudes.
#

require 'fileutils'
require_relative 'cours'
require_relative 'cours-texte'
require_relative 'motifs'

###################################################
# CONSTANTES GLOBALES.
###################################################

# Nom de fichier pour depot par defaut.
DEPOT_DEFAUT = '.cours.txt'


###################################################
# Fonctions pour debogage et traitement des erreurs.
###################################################

# Pour generer ou non des traces de debogage avec la function debug,
# il suffit d'ajouter/retirer '#' devant '|| true'.
DEBUG=false #|| true

def debug( *args )
  return unless DEBUG

  puts "[debug] #{args.join(' ')}"
end

def erreur( msg )
  STDERR.puts "*** Erreur: #{msg}"
  STDERR.puts

  puts aide if /Commande inconnue/ =~ msg

  exit 1
end

def erreur_nb_arguments( *args )
  erreur "Nombre incorrect d'arguments: <<#{args.join(' ')}>>"
end

###################################################
# Fonction d'aide: fournie, pour uniformite.
###################################################

def aide
    <<EOF
NOM
  #{$0} -- Script pour gestion academique (banque de cours)

SYNOPSIS
  #{$0} [--depot=fich] commande [options-commande] [argument...]

COMMANDES
  aide          - Emet la liste des commandes
  ajouter       - Ajoute un cours dans la banque de cours
                  (les prealables doivent exister)
  desactiver    - Rend inactif un cours actif
                  (ne peut plus etre utilise comme nouveau prealable)
  init          - Cree une nouvelle base de donnees pour gerer des cours
                  (dans './#{$DEPOT_DEFAUT}' si --depot n'est pas specifie)
  lister        - Liste l'ensemble des cours de la banque de cours
                  (ordre croissant de sigle)
  nb_credits    - Nombre total de credits pour les cours indiques
  prealables    - Liste l'ensemble des prealables d'un cours
                  (par defaut: les prealables directs seulement)
  reactiver     - Rend actif un cours inactif
  supprimer     - Supprime un cours de la banque de cours
  trouver       - Trouve les cours qui matchent un motif
EOF
end

###################################################
# Fonctions pour manipulation du depot.
#
# Fournies pour simplifier le devoir et assurer au depart un
# fonctionnement minimal du logiciel.
###################################################

def definir_depot
  depot = valider_option(/^--depot=/, ARGV[0])
  depot ||= DEPOT_DEFAUT
  depot
end

def init( depot )
  detruire = valider_option(/^--detruire$/, ARGV[0])

  if File.exists? depot
	  if detruire
      FileUtils.rm_f depot # On detruit le depot existant si --detruire est specifie.
    else
      erreur "Le fichier '#{depot}' existe.
              Si vous voulez le detruire, utilisez 'init --detruire'."
    end
  end

  FileUtils.touch depot
end

def charger_les_cours( depot )
  erreur "Le fichier '#{depot}' n'existe pas!" unless File.exists? depot

  # On lit les cours du fichier.
  IO.readlines( depot ).map do |ligne|
    # On ignore le saut de ligne avec chomp.
    CoursTexte.creer_cours( ligne )
  end
end

def sauver_les_cours( depot, les_cours )
  # On cree une copie de sauvegarde.
  FileUtils.cp depot, "#{depot}.bak"

  # On sauve les cours dans le fichier.
  #
  # Ici, on aurait aussi pu utiliser map plutot que each. Toutefois,
  # comme la collection resultante n'aurait pas ete utilisee,
  # puisqu'on execute la boucle uniquement pour son effet de bord
  # (ecriture dans le fichier), ce n'etait pas approprie.
  #
  File.open( depot, "w" ) do |fich|
    les_cours.each do |c|
      CoursTexte.sauver_cours( fich, c )
    end
  end
end


#################################################################
# Les fonctions pour les diverses commandes de l'application.
#################################################################

def lister( les_cours )
  inactif = valider_option(/^--avec_inactifs/, ARGV[0])
  format = valider_option(/^--format=/, ARGV[0])
  separateur_prealables = valider_option(/^--separateur_prealables=/, ARGV[0])

  liste_cours = inactif==true ? les_cours : les_cours.select { |cours| cours.actif? }

  resultat = liste_cours.map { |cours| cours.to_s(format, separateur_prealables) }
  resultat = resultat.empty? ? nil : resultat.sort{ |x, y| x <=> y }.join("\n") << "\n"

  [les_cours, resultat]
end

def ajouter( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def nb_credits( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def supprimer( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def trouver( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def desactiver( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

def reactiver( les_cours )
  [les_cours, nil]
end

def prealables( les_cours )
  [les_cours, nil] # A MODIFIER/COMPLETER!
end

#######################################################
# Fonctions secondaires
#######################################################

def valider_option( attendu, obtenu )
	if attendu =~ obtenu
	  ARGV.shift
    match = /=/.match obtenu
    return match.nil? ? true : match.post_match
  end
	
  nil
end

#######################################################
# Les differentes commandes possibles.
#######################################################
COMMANDES = [:ajouter,
             :desactiver,
             :init,
             :lister,
             :nb_credits,
             :prealables,
             :reactiver,
             :supprimer,
             :trouver,
            ]

#######################################################
# Le programme principal
#######################################################

#
# La strategie utilisee pour uniformiser le traitement des commandes
# est la suivante (strategie differente de celle utilisee par ga.sh
# dans le devoir 1).
#
# Une commande est mise en oeuvre par une fonction auxiliaire.
# Contrairement au devoir 1, c'est cette fonction *qui modifie
# directement ARGV* (ceci est possible en Ruby, alors que ce ne
# l'etait pas en bash), et ce selon les arguments consommes.
#
# La fonction appelee pour realiser une commande ne retourne donc pas
# le nombre d'arguments utilises. Comme on desire utiliser une
# approche fonctionnelle, la fonction retourne plutot deux resultats
# (tableau de taille 2):
#
# 1. La liste des cours resultant de l'execution de la commande
#    (donc liste possiblement modifiee)
#
# 2. L'information a afficher sur stdout (nil lorsqu'il n'y a aucun
#    resultat a afficher).
#

begin
  # On definit le depot a utiliser, possiblement via l'option.
  depot = definir_depot

  debug "On utilise le depot suivant: #{depot}"

  # On analyse la commande indiquee en argument.
  commande = (ARGV.shift || :aide).to_sym
  (puts aide; exit 0) if commande == :aide

  erreur "Commande inconnue: '#{commande}'" unless COMMANDES.include? commande

  # La commande est valide: on l'execute et on affiche son resultat.
  if commande == :init
    init( depot )
  else
    les_cours = charger_les_cours( depot )
    les_cours, resultat = send commande, les_cours
    print resultat if resultat   # Note: print n'ajoute pas de saut de ligne!
    sauver_les_cours( depot, les_cours )
  end

  erreur "Argument(s) en trop: '#{ARGV.join(' ')}'" unless ARGV.empty?
end
