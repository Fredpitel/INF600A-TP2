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

  SIGLE =  /^[A-Z]{3}[0-9]{4}$/
  TITRE = /^.+$/
  NOMBRE = /^[\d]+$/
  PREALABLES = /^([A-Z]{3}[0-9]{4} *)+$/

  # Motif pour un cours complet
  COURS = /^[A-Z]{3}[0-9]{4} +('|").+('|") +[\d]+( +[A-Z]{3}[0-9]{4})*$/
end
