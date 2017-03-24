require_relative 'test_helper'

describe "GestionAcademique" do
  describe "prealables" do
    it_ "signale une erreur lorsque fichier inexistant", :intermediaire do
      FileUtils.rm_f '.cours.txt'
      genere_erreur( /fichier.*[.]cours.txt.*existe pas/ ) do
        ga( 'prealables INF3105' )
      end
    end

    it_ "signale une erreur lorsque le sigle n'existe pas", :intermediaire do
      avec_fichier '.cours.txt'do
        genere_erreur( /Aucun cours.*XXX000/ ) do
          ga( 'prealables XXX0000' )
        end
      end
    end

    context "banque de cours avec plusieurs cours" do
      let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }

      it_ "retourne rien lorsqu'aucun prealable" do
        avec_fichier '.cours.txt', lignes do
          execute_sans_sortie_ou_erreur do
            ga( 'prealables INF1120' )
          end
        end
      end

      it_ "retourne les prealables directs, en ordre" do
        avec_fichier '.cours.txt', lignes do
          genere_sortie( ['INF1130', 'INF2120'] ) do
            ga( 'prealables INF3105' )
          end
        end
      end

      it_ "retourne tous les prealables, directs et indirects, en ordre", :avance do
        avec_fichier '.cours.txt', lignes do
          genere_sortie( ['INF1120', 'INF1130', 'INF2120'] ) do
            ga( 'prealables --tous INF3105' )
          end
        end
      end
    end

    context "banque de cours avec plusieurs cours dont plusieurs prealables indirects" do
      let(:lignes) { IO.readlines("Tests/cours.txt.8") }

      it_ "retourne tous les prealables, directs et indirects, en ordre", :avance do
        avec_fichier '.cours.txt', lignes do
          genere_sortie( ['INF1120', 'INF1130', 'INF2120', 'INF3105', 'INF3135', 'INF4100', 'INF7341'] ) do
            ga( 'prealables --tous INF7440' )
          end
        end
      end
    end
  end
end
