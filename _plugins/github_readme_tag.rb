require "erb"
require "octokit"

module Jekyll
  class GitHubReadmeTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @link = text.gsub(/.*github\.com\//, "").strip

      client = get_client()

      readme_html = client.readme(@link, accept: "application/vnd.github.html")
      repo = client.repository(@link)

      @github_user = repo.owner.login
      @github_project_url = repo.html_url
      @github_project_name = repo.name
      @github_project_desc = repo.description
      @github_readme_text = readme_html
    end

    def render(context)
      baseurl = context.registers[:site].config['baseurl']
      @github_logo = "#{baseurl}/assets/images/github_logo.svg"
      return template
    end

    def get_client
      token = ENV["GITHUB_TOKEN"]
      if token
        return Octokit::Client.new(access_token: token)
      end

      return Octokit::Client.new()
    end

    def template
<<HTML_TEMPLATE
        <div class="readme_container">
          <div class="readme_overview">
            <h2>
              <img class="readme_github_logo" src="#{@github_logo}" alt="GitHub logo">
              <a href="https://github.com/#{@github_user}">
                #{@github_user}
              </a>
              /
              <a style="font-weight: 600;" href="#{@github_project_url}">
                #{@github_project_name}
              </a>
            </h2>
            <h3>
              #{@github_project_desc}
            </h3>
          </div>
          <div class="github_readme_body">
            <p>
            #{@github_readme_text}
            </p>
          </div>
          <div class="github_button_container">
            <a class="github_button" href="#{@github_project_url}">View on GitHub</a>
          </div>
        </div>
HTML_TEMPLATE
    end


  end
end

Liquid::Template.register_tag('github', Jekyll::GitHubReadmeTag)
