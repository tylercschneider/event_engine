class WidgetCreated < EventEngine::EventDefinition
  event_name :widget_created
  event_type :domain

  input :widget
  required_payload :sku, from: :widget, attr: :sku
end
