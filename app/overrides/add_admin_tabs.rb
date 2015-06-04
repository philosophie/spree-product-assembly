Deface::Override.new(:virtual_path => "spree/admin/shared/_product_tabs",
                     :name => "product_collection_admin_product_tabs",
                     :insert_bottom => "[data-hook='admin_product_tabs']",
                     :partial => "spree/admin/shared/product_collection_product_tabs",
                     :disabled => false)
