require 'rubygems'
require 'sinatra'
require 'active_support/all'
require 'rouge'
require 'open-uri'

helpers do
  def syntaxify(url, mode, options = {})
    url  = URI.decode(url).gsub(%r{/blob/}, '/raw/')
    formatting_options = {
      wrap: false,
      css_class: false,
      line_numbers: false
    }.merge(options)
    formatter = Rouge::Formatters::HTML.new formatting_options
    lexer = Rouge::Lexer.find_fancy(mode)
    html = formatter.format(lexer.lex(open(url).read))
    "<pre><code>#{html}</code></pre>"
  rescue => e
    halt 500, "No such theme found: #{theme}" unless formatter
    halt 404, "URL not found: #{url}" if e.message.start_with?('404')
  end
end

get '/' do
  if params['url']
    theme = params.fetch 'theme', 'github'
    syntaxify params['url'], params['mode'], inline_theme: theme
  else
    lexer_list = Rouge::Lexer.all.map do |lex|
      "<li>#{lex.to_s.demodulize.underscore}</li>"
    end
    theme_list = Rouge::Theme.registry.map { |lex| "<li>#{lex[0]}</li>" }
    html  = ''
    html += 'Quickly syntax highlight a Github URL.<br/><br/>'
    html += '<code>GET /&lt;mode&gt;/?url=&lt;url&gt;&theme=&lt;theme&gt;</code>'
    html += "<h3>Available Themes</h3><ul>#{theme_list.join}</ul>"
    html += "<h3>Available Modes</h3><ul>#{lexer_list.join}</ul>"
    html
  end
end

get '/:mode/' do
  theme = params.fetch 'theme', 'github'
  syntaxify params['url'], params['mode'], inline_theme: theme
end
