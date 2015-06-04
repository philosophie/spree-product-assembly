Deface::Override.new(:virtual_path => "spree/admin/products/_form",
                     :name => "product_collection_admin_product_form_right",
                     :insert_bottom => "[data-hook='admin_product_form_left']",
                     :partial => "spree/admin/products/product_collection_fields",
                     :disabled => false)
