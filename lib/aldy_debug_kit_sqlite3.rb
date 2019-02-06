require "aldy_debug_kit_sqlite3/version"

module AldyDebugKitSqlite3
  # Your code goes here...
  def self.greet
    'Hey! I am Tsukasa Maruyama! Call me Aldy!'
  end

  def self.getTables
    table_names = ActiveRecord::Base.connection.tables
    models = []
    table_names.each do |table_name|
      model_name = table_name.classify
      if !["ArInternalMetadatum"].include?(model_name)
        column_names = model_name.constantize.column_names
        rows = model_name.constantize.all
        model = {"table_name" => table_name, "model_name" => model_name, "column_names" => column_names, "rows" => rows}
        models.push(model)
      end
    end
    return models
  end

  def self.setUp

    template = %Q{
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8" />
        <title>show tables</title>
        <link rel="stylesheet" type="text/css" href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

        <style>
        body {
          margin: 3% 5%
        }
        </style>
        </head>
        <body >

        <% @models.each do |model| %>
        <div class="page-header">
          <h1>
            <%= model["table_name"] %>
            <a class="btn btn-primary" data-toggle="collapse" href="#collapseExample_<%= model["model_name"] %>" role="button" aria-expanded="false" aria-controls="collapseExample">
            Show/Hedden
          </a>
          </h1>
        </div>
        <div class="collapse" id="collapseExample_<%= model["model_name"] %>">
        <table class="table table-bordered table-striped table-sm">
          <thead class="thead-dark">
            <tr>
            <% model["column_names"].each do |column_name|  %>
              <th scope="col"><%= column_name %></th>
            <% end %>
            </tr>
          </thead>
          <tbody>
          <% model["rows"].each do |row|  %>
            <tr>
            <% model["column_names"].each do |column_name|  %>
              <td><%= row[column_name] %></td>
            <% end %>
            </tr>
          <% end %>
          </tbody>
        </table>
        </div>
        <% end %>
        </body>
        </html>
    }

    File.open("views/aldy_show_sqlite3_tables.erb","w") do |text|
        template.each_line do |line|
          text.puts(line)
        end
    end

    action_text = %Q{
    get '/models' do
      @models = AldySqlite3ShowTable.getTables
      erb :aldy_show_sqlite3_tables
    end
    }

    File.open("show_table_action.rb","w") do |text|
        action_text.each_line do |line|
          text.puts(line)
        end
    end

    puts "Setup finished!"
  end
end
