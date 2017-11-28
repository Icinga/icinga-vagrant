datacat { "/tmp/demo1":
  template_body => "<% @data.keys.sort.each do |k| %><%= k %>: <%= @data[k] %>, <% end %>",
}

datacat_fragment { "foo":
  target => '/tmp/demo1',
  data => { foo => "one" },
}

datacat_fragment { "bar":
  target => '/tmp/demo1',
  data => { bar => "two" },
}
