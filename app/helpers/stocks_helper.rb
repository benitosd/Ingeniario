# app/helpers/stocks_helper.rb
module StocksHelper
    def qr_code_tag(stock, size: :medium)
      sizes = {
        small: 150,
        medium: 250,
        large: 400
      }
      
      content_tag :div, class: "qr-code qr-code-#{size}" do
        raw stock.generate_qr_code_svg
      end
    end
  end