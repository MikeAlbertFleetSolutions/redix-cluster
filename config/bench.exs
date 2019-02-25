use Mix.Config

config :redix_cluster,
  cluster_nodes: [%{host: "172.16.43.5", port: 6379},
                     %{host: "172.16.43.6", port: 6380},
                 ],
  pool_size: 5,
  pool_max_overflow: 0,

# connection_opts
  socket_opts: []

config :eredis_cluster,
  init_nodes: [{'172.16.43.5',6379},
               {'172.16.43.6',6380},
               ],
  pool_size: 5,
  pool_max_overflow: 0
