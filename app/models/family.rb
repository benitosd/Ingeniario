class Family < ApplicationRecord
    searchable do
        text :nombre_familia
      end
end
