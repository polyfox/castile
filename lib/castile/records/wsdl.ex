defmodule Castile.Records.WSDL do
  @moduledoc """
  WSDL related records. Used when parsing Erlsom output.
  """
  import Record
  defrecord :wsdl_definitions, :"wsdl:tDefinitions",      [:attrs, :namespace, :name,     :docs,   :any,    :imports, :types, :messages, :port_types, :bindings, :services]
  defrecord :wsdl_service,     :"wsdl:tService",          [:attrs, :name,      :docs,     :choice, :ports]
  defrecord :wsdl_port,        :"wsdl:tPort",             [:attrs, :name,      :binding,  :docs,   :choice]
  defrecord :wsdl_binding,     :"wsdl:tBinding",          [:attrs, :name,      :type,     :docs,   :choice, :ops]
  defrecord :wsdl_binding_operation,   :"wsdl:tBindingOperation", [:attrs, :name,      :docs,     :choice, :input,  :output, :fault]
  defrecord :wsdl_import,      :"wsdl:tImport",           [:attrs, :namespace, :location, :docs]
  defrecord :wsdl_port_type,   :"wsdl:tPortType",         [:attrs, :name, :docs, :operations]
  defrecord :wsdl_part,        :"wsdl:tPart",             [:attrs, :name,      :element, :type,   :docs]
  defrecord :wsdl_message,     :"wsdl:tMessage",          [:attrs, :name,      :docs,    :choice, :part]
  defrecord :wsdl_operation,   :"wsdl:tOperation",        [:attrs, :name,      :parameterOrder,     :docs, :any,  :choice]
  defrecord :wsdl_request_response, :"wsdl:request-response-or-one-way-operation", [:attrs, :input, :output, :fault]
  defrecord :wsdl_param, :"wsdl:tParam", [:attrs, :name, :message, :docs]
end
