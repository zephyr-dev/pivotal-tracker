module PivotalTracker
  class Iteration
    include Virtusable

    class << self
      def all(project, options={})
        params = PivotalTracker.encode_options(options)
        parse(Client.connection["/projects/#{project.id}/iterations#{params}"].get)
      end

      def current(project)
        array = parse(Client.connection["projects/#{project.id}/iterations/current"].get)
        array.first if array
      end

      def done(project, options={})
        params = PivotalTracker.encode_options(options)
        parse(Client.connection["/projects/#{project.id}/iterations/done#{params}"].get)
      end

      def backlog(project, options={})
        params = PivotalTracker.encode_options(options)
        parse(Client.connection["/projects/#{project.id}/iterations/backlog#{params}"].get)
      end

      def current_backlog(project, options={})
        params = PivotalTracker.encode_options(options)
        parse(Client.connection["/projects/#{project.id}/iterations/current_backlog#{params}"].get)
      end
    end

    attribute :id, Integer
    attribute :number, Integer
    attribute :start, DateTime
    attribute :finish, DateTime
    attribute :team_strength, Float
    # has_many :stories, Story, :xpath => './/stories'

  end
end
