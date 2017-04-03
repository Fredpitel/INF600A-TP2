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
  options = get_options([:depot])
  options[:depot] ||= DEPOT_DEFAUT
end

def init( depot )
  options = get_options([:detruire])

  if File.exists? depot
	  if options[:detruire]
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
  options = get_options([:avec_inactifs, :format, :separateur_prealables])

  liste_cours = options[:avec_inactifs] ? les_cours : les_cours.select { |cours| cours.actif? }
  resultat = liste_cours.empty? ? nil : formater_resultat(liste_cours, options)

  [les_cours, resultat]
end

def ajouter( les_cours )
  if ARGV.empty?
    ARGF.each { |ligne| 
      les_cours << creer_cours(ligne.scan(/(?<=[\"\']).*(?=[\"\'])|\w+/), les_cours) unless ligne.strip.empty? 
    }
  else
    les_cours << creer_cours(ARGV, les_cours)
  end

  [les_cours, nil]
end

def nb_credits( les_cours )
  total = ARGV.empty? ? 0 : ARGV.map { |sigle| get_cours(sigle, les_cours).nb_credits.to_i }.reduce(:+)
  ARGV.clear
  [les_cours, total.to_s << "\n"]
end

def supprimer( les_cours )
  if ARGV.empty?
    ARGF.read.scan(/\w+/).map { |sigle| les_cours.delete(get_cours(sigle, les_cours)) }
  else
    les_cours.delete(get_cours(ARGV.shift, les_cours))
  end

  [les_cours, nil]
end

def trouver( les_cours )
  options = get_options([:avec_inactifs, :cle_tri, :format])

  liste_cours = (options[:avec_inactifs] ? les_cours : les_cours.select { |cours| cours.actif? })
                .select { |cours| /#{ARGV[0]}/i =~ cours.to_s }
  ARGV.shift

  resultat = liste_cours.empty? ? nil : formater_resultat(liste_cours, options)

  [les_cours, resultat]
end

def desactiver( les_cours )
  get_cours(ARGV.shift, les_cours).desactiver

  [les_cours, nil]
end

def reactiver( les_cours )
  get_cours(ARGV.shift, les_cours).activer

  [les_cours, nil]
end

def prealables( les_cours )
  options = get_options([:tous])
  cours = get_cours(ARGV.shift, les_cours)

  prealables = options[:tous] ? get_prealables(cours.prealables, les_cours) : cours.prealables

  resultat = prealables.empty? ? nil : prealables.flatten.uniq.sort.join("\n") << "\n"

  [les_cours, resultat]
end

def get_prealables ( prealables, les_cours )
  prealables.map { |pre|
    cours = get_cours( pre.to_s, les_cours )
    cours.prealables.empty? ? pre : get_prealables(cours.prealables, les_cours) << pre
  }
end

#######################################################
# Fonctions secondaires
#######################################################
def get_options( sym )
  Hash[ sym.map { |sym| [sym, valider_option(/^--#{sym.to_s}/, ARGV[0])] } ]
end

def valider_option( attendu, obtenu )
	if attendu =~ obtenu
	  ARGV.shift
    match = /=/.match obtenu
    match.nil? ? true : match.post_match
  else
    nil
  end
end

def formater_resultat(liste_cours, options)
  options[:separateur_prealables] ||= CoursTexte::SEPARATEUR_PREALABLES

  liste_triee = options[:cle_tri] == "titre" ? liste_cours.sort_by(&:titre) : liste_cours.sort_by(&:sigle)
  liste_triee.map { |cours| cours.to_s(options[:format], options[:separateur_prealables]) }.join("\n") << "\n"
end

def creer_cours(data_cours, les_cours)
  cours = CoursTexte.creer_cours(get_params(data_cours))
  valider_cours(cours, les_cours)
end

def get_params(data_cours)
  params = data_cours.shift(3)
  params << (data_cours.empty? ? nil : data_cours.join(':'))
  data_cours.clear
  params.join(',') << ",#{CoursTexte::ACTIF}"
end

def valider_cours(cours, les_cours)
  erreur "Sigle de motif incorect." unless cours.sigle =~ Motifs::SIGLE
  erreur "Un cours avec le meme sigle existe deja." if les_cours.include? cours
  cours.prealables.each { |pre|
    erreur "Prealable invalide car Sigle incorrect." unless Motifs::SIGLE =~ pre
    erreur "Prealable invalide car inexistant ou inactif: #{pre}" unless les_cours.any? { |cours| (cours.sigle == pre && cours.actif?) }
  }
  cours
end

def get_cours(sigle, les_cours)
  erreur "Format de sigle incorrect: #{sigle}" unless sigle =~ Motifs::SIGLE
  cours = les_cours.find { |cours| cours.sigle.to_s == sigle  }
  erreur "Aucun cours: #{sigle}" unless cours
  cours
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
