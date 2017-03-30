require_relative 'cours-texte'
#
# Module qui regroupe des constantes definissant les divers motifs
# pour identifier les champs d'un cours.
#
module Motifs
  # Motifs mots representant sigle, titre, nommbre (de credits) et prealables.
  #
  # Rappel: les deux facons suivantes permettent de definir un objet Rexexp.
  #   %r{...}
  #   /.../

  SIGLE_STR = "[A-Z]{3}[0-9]{3}[A-Z0-9]"
  TITRE_STR = ".+"
  NOMBRE_STR =  '[\d]+'
  PREALABLES_STR = "( *#{SIGLE_STR})+"

  SIGLE =  /^#{SIGLE_STR}$/
  TITRE = /^#{TITRE_STR}$/
  NOMBRE = /^#{NOMBRE_STR}$/
  PREALABLES = /^#{PREALABLES_STR}$/

  # Motif pour un cours complet
  COURS = /^#{SIGLE_STR} +('|")#{TITRE_STR}('|") +#{NOMBRE_STR}(#{PREALABLES_STR})?$/
end
