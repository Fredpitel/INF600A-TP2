require_relative 'test_helper'

DEFAUT=".cours.txt"

describe "GestionAcademique" do
  [DEFAUT, '.foo.txt'].each do |depot|
    niveau         = depot == DEFAUT ? :base : :intermediaire
    argument_depot = depot == DEFAUT ? ''    : "--depot=#{depot} "

    describe "init" do
      after  { FileUtils.rm_f depot }

      context "le depot #{depot} n'existe pas" do
        before { FileUtils.rm_f depot }

        it_ "cree le depot #{depot} lorsqu'aucune option n'est specifiee", niveau do
          execute_sans_sortie_ou_erreur do
            ga( "#{argument_depot}init" )
          end
          assert File.zero? depot
        end

        it_ "cree le depot #{depot} lorsque l'option --detruire est specifies", niveau do
          execute_sans_sortie_ou_erreur do
            ga( "#{argument_depot}init --detruire" )
          end
          assert File.zero? depot
        end
      end

      context "le depot #{depot} existe" do
        before { FileUtils.touch depot }

        it_ "signale une erreur lorsque l'option --detruire n'est pas specifiee", :intermediaire do
          genere_erreur( /fichier.*#{depot}.*existe.*--detruire/ ) do
            ga( "#{argument_depot}init" )
          end
          assert File.exist? depot
        end

        it_ "cree le depot #{depot} lorsque l'option --detruire est specifies", niveau do
          execute_sans_sortie_ou_erreur do
            ga( "#{argument_depot}init --detruire" )
          end
          assert File.zero? depot
        end
      end
    end
  end
end
