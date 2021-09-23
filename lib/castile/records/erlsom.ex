defmodule Castile.Records.Erlsom do
  @moduledoc """
  Erlsom parser records. Used for processing erlsom XSD metadata.
  """
  import Record
  @doc "The XSD model"
  defrecord :model, :model, [:types, :namespaces, :target_namespace, :type_hierarchy, :any_attribs, :value_fun]
  @doc "XSD type representation"
  defrecord :type, [:name, :tp, :els, :attrs, :anyAttr, :nillable, :nr, :nm, :mx, :mxd, :typeName]
  @doc "XSD element representation"
  defrecord :el,   [:alts, :mn, :mx, :nillable, :nr]
  @doc "XSD alternative representation"
  defrecord :alt,  [:tag, :type, :nxt, :mn, :mx, :rl, :anyInfo]
  @doc "XML attribute"
  defrecord :attr, :att, [:name, :nr, :opt, :tp]

  # erlsom internals
  defrecord :ns, [:uri, :prefix, :element_form_default]
  defrecord :qname, [:uri, :local_part, :prefix, :mapped_prefix]
end
