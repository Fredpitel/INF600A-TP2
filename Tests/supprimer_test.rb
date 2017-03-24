require_relative 'test_helper'

describe "GestionAcademique" do
  let(:bd)  { '.cours.txt' }

  describe "supprimer" do
    it_ "signale une erreur lorsque depot inexistant", :intermediaire do
      FileUtils.rm_f bd
      genere_erreur( /fichier.*[.]cours.txt.*existe pas/ ) do
        ga( 'supprimer INF1120' )
      end
    end

    context "banque de cours avec plusieurs cours" do
      let(:lignes) { IO.readlines("Tests/cours.txt.5+1") }
      let(:attendu) { ['INF1120 "Programmation I" ()',
                       'INF1130 "Mathematiques pour informaticien" ()',
                       'INF2120 "Programmation II" (INF1120)',
                       'INF3105 "Structures de donnees et algorithmes" (INF1130:INF2120)',
                       'INF3135 "Construction et maintenance de logiciels" (INF1120)',
                      ]
      }

      it_ "signale une erreur lorsque le sigle n'existe pas", :intermediaire do
        avec_fichier bd, lignes do
          genere_erreur( /Aucun cours.*INF9999/ ) do
            ga( "supprimer INF9999" )
          end
        end
      end

      it_ "signale une erreur lorsqu'il y a un argument en trop", :intermediaire do
        avec_fichier bd, lignes do
          genere_sortie_et_erreur( [], /Argument.*en trop/ ) do
            ga( 'supprimer INF2120 foo' )
          end
        end
      end

      it_ "supprime le cours lorsque le sigle existe" do
        nouveau_contenu = avec_fichier bd, lignes, :conserver do
          execute_sans_sortie_ou_erreur do
            ga( "supprimer   INF2120   " )
          end
        end

        nouveau_contenu.find { |l| l =~ /^INF2120/ }.must_be_nil
        nouveau_contenu.size.must_equal 5
        FileUtils.rm_f bd
      end

      it_ "supprime les divers cours specifies via stdin", :avance do
        avec_fichier 'data.txt', ["  INF1120 MAT3140  ", "  INF2120  "] do
          nouveau_contenu = avec_fichier bd, lignes, :conserver do
            execute_sans_sortie_ou_erreur do
              ga( "supprimer < data.txt" )
            end
          end

          nouveau_contenu.find { |l| l =~ /^INF1120/ }.must_be_nil
          nouveau_contenu.find { |l| l =~ /^INF2120/ }.must_be_nil
          nouveau_contenu.find { |l| l =~ /^MAT3140/ }.must_be_nil
          nouveau_contenu.size.must_equal 3

          FileUtils.rm_f bd
        end
      end

      it_ "supprime les divers cours specifies via stdin", :avance do
        avec_fichier 'data.txt', ["  INF1120 MAT3140  ", "  INF220  "] do
          avec_fichier bd, lignes, :conserver do
            FileUtils.cp bd, "#{bd}.avant"
            genere_erreur( /Format.*incorrect.*INF220/ ) do
              ga( "supprimer < data.txt" )
            end
          end
        end

        %x{cmp #{bd} #{bd}.avant; echo $?}.must_equal "0\n"

        FileUtils.rm_f bd
        FileUtils.rm_f "#{bd}.avant"
      end
    end
  end
end
