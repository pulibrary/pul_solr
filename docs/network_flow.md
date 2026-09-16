# Solr Network Flow


## Flow Diagrams

```mermaid
sequenceDiagram
    box Loading authorities every month
      actor User
      participant Application
      participant NginxPlus
      participant Solr
    end
        User->>Application: User makes a query
        Application->>NginxPlus: Application goes to NginxPlus and asks for Solr
        NginxPlus->>Solr: Send query to one of the three upstream servers
        Note over NginxPlus,Solr: 7 minute timeout (set in solr nginxplus conf file)


```

## Application timeouts

| Application | timeout value | timeout source | set or default |
| ----------- | ------------- | -------------- | -------------- |
| Digital Collections | 15_000 milliseconds | [Finch, via Req](https://finch.hexdocs.pm/0.23.0/Finch.html#t:request_opt/0) | default |

