require_relative 'test_helper'

describe "GestionAcademique" do
  describe "deactiver et reactiver" do
    it_ "signalent une erreur lorsque depot inexistant", :intermediaire do
      FileUtils.rm_f '.cours.txt'

      genere_erreur( /fichier.*[.]cours.txt.*existe pas/ ) do
        ga( 'desactiver INF1120' )
      end

      genere_erreur( /fichier.*[.]cours.txt.*existe pas/ ) do
        ga( 'reactiver INF1120' )
      end
    end

    context "banque de cours avec plusieurs cours" do
      let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }

      it_ "signalent une erreur lorsque le sigle n'existe pas", :intermediaire do
        avec_fichier '.cours.txt', lignes do
          genere_erreur( /Aucun cours.*INF9999/ ) do
            ga( "desactiver INF9999" )
          end

          genere_erreur( /Aucun cours.*INF9999/ ) do
            ga( "reactiver INF9999" )
          end
        end
      end

      describe "desactiver" do
        it_ "signale une erreur lorsque le sigle est deja inactif", :intermediaire do
          avec_fichier '.cours.txt', lignes do
            genere_erreur( /deja inactif.*MAT3140/i ) do
              ga( "desactiver MAT3140" )
            end
          end
        end

        it_ "change le statut du cours lorsque le sigle existe" do
          nouveau_contenu = avec_fichier '.cours.txt', lignes, :conserver do
            execute_sans_sortie_ou_erreur do
              ga( "desactiver INF1120" )
            end
          end

          nouveau_contenu.find { |l| l =~ /^INF1120/ }
            .must_match( /#{CoursTexte::SEPARATEUR}#{CoursTexte::INACTIF}/ )

          FileUtils.rm_f '.cours.txt'
        end
      end

      describe "reactiver" do
        it_ "signale une erreur lorsque le sigle est deja actif", :intermediaire do
          avec_fichier '.cours.txt', lignes do
            genere_erreur( /deja actif.*INF1120/i ) do
              ga( "reactiver INF1120" )
            end
          end
        end

        it_ "change le statut du cours lorsque le sigle existe" do
          nouveau_contenu = avec_fichier '.cours.txt', lignes, :conserver do
            execute_sans_sortie_ou_erreur do
              ga( "reactiver MAT3140" )
            end
          end

          nouveau_contenu.find { |l| l =~ /^MAT3140/ }
            .must_match( /#{CoursTexte::SEPARATEUR}#{CoursTexte::ACTIF}/ )

          FileUtils.rm_f '.cours.txt'
        end
      end
    end
  end
end
