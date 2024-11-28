# Changelog

{{- with (datasource "changelog") }}
{{- range $version, $changes := .changelog }}
## {{ $version  }}
{{- range $change := $changes }}
- {{ $change  }}
{{- end }}
{{- end }}
{{- end }}
