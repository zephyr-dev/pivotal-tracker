module PivotalTracker
  class Story
    include HappyMapper

    class << self
      def all(project, options={})
        params = PivotalTracker.encode_options(options)
        stories = parse(Client.connection["/projects/#{project.id}/stories#{params}"].get)
        stories.each { |s| s.project_id = project.id }
        return stories
      end
    end

    tag "story"

    element :id, Integer
    element :url, String
    element :created_at, DateTime
    element :accepted_at, DateTime
    element :project_id, Integer

    element :name, String
    element :description, String
    element :story_type, String
    element :estimate, Integer
    element :current_state, String
    element :requested_by, String
    element :owned_by, String
    element :labels, String
    element :jira_id, Integer
    element :jira_url, String
    element :other_id, Integer
    element :integration_id, Integer

    has_many :attachments, Attachment, :tag => 'attachments'

    def initialize(attributes={})
      if attributes[:owner]
        self.project_id = attributes.delete(:owner).id
      end
      update_attributes(attributes)
    end

    def create
      return self if project_id.nil?
      response = Client.connection["/projects/#{project_id}/stories"].post(self.to_xml, :content_type => 'application/xml')
      new_story = Story.parse(response)
      new_story.project_id = project_id
      return new_story
    end

    def update(attrs={})
      update_attributes(attrs)
      response = Client.connection["/projects/#{project_id}/stories/#{id}"].put(self.to_xml, :content_type => 'application/xml')
      return Story.parse(response)
    end

    def delete
      Client.connection["/projects/#{project_id}/stories/#{id}"].delete
    end

    def notes
      @notes ||= Proxy.new(self, Note)
    end

    def tasks
      @tasks ||= Proxy.new(self, Task)
    end

    def upload_attachment(filename)
      Attachment.parse(Client.connection["/projects/#{project_id}/stories/#{id}/attachments"].post(:Filedata => File.new(filename)))
    end

    def move_to_project(new_project)
      case new_project.class
        when PivotalTracker::Story
          update :project_id => new_project.project_id
        when PivotalTracker::Project
          update :project_id => new_project.id
        when String
          update :project_id => new_project.to_i
        when Integer
          update :project_id => new_project
      end
    end

    protected

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.story {
            xml.name "#{name}"
            xml.description "#{description}"
            xml.story_type "#{story_type}"
            xml.estimate "#{estimate}"
            xml.current_state "#{current_state}"
            xml.requested_by "#{requested_by}"
            xml.owned_by "#{owned_by}"
            xml.labels "#{labels}"
            xml.project_id "#{project_id}"
            # See spec
            # xml.jira_id "#{jira_id}"
            # xml.jira_url "#{jira_url}"
            xml.other_id "#{other_id}"
            xml.integration_id "#{integration_id}"
          }
        end
        return builder.to_xml
      end

      def update_attributes(attrs)
        attrs.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value.join(',') : value )
        end
      end
  end
end
