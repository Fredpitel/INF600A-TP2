require_relative 'dbc'
require_relative 'motifs'

#
# Objet pour modeliser un cours.
#
# Tous les champs sont immuables (non modifiables) a l'exception du
# champ qui indique si le cours est actif ou non.
#
class Cours
  include Comparable


  def initialize( sigle, titre, nb_credits, *prealables, actif: true )
    DBC.require( sigle.kind_of?(Symbol) && /^#{Motifs::SIGLE}$/ =~ sigle,
                 "Sigle incorrect: #{sigle}!?" )
    DBC.require( !titre.strip.empty?,
                 "Titre vide: '#{titre}'" )
    DBC.require( nb_credits.to_i > 0,
                 "Nb. credits invalides: #{nb_credits}!?" )

    # A COMPLETER.
  end

  #
  # Formate un cours selon les indications specifiees par le_format:
  #   - %S: Sigle du cours
  #   - %T: Titre du cours
  #   - %C: Nombre de credits du cours
  #   - %P: Prealables du cours
  #   - %A: Cours actif ou non?
  #
  # Des indications de largeur, justification, etc. peuvent aussi etre
  # specifiees, par exemple, %-10T, %-.10T, etc.
  #
  def to_s( le_format = nil, separateur_prealables = CoursTexte::SEPARATEUR_PREALABLES )
    # Format simple par defaut, pour les cas de tests de base.a
    if le_format.nil?
      return format("%s%s \"%-10s\" (%s)",
                    sigle,
                    actif? ? "" : "?",
                    titre,
                    prealables.join(separateur_prealables))
    end

    fail "Cas non traite: to_s( #{le_format}, #{separateur_prealables} )"
  end


  #
  # Ordonne les cours selon le sigle.
  #
  def <=>( autre )
    # A COMPLETER.
  end

  #
  # Rend un cours inactif.
  #
  def desactiver
    DBC.require( actif?, "Cours pas actif: #{self}" )

    # A COMPLETER.
  end

  #
  # Rend un cours actif.
  #
  def activer
    DBC.require( !actif?, "Cours deja actif: #{self}" )

    # A COMPLETER.
  end

  #
  # Determine si le cours est actif ou non.
  #
  def actif?
    # A COMPLETER.
  end
end
