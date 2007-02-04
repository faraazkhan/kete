module ConfigureAsKeteContentItem
  unless included_modules.include? ConfigureAsKeteContentItem
    def self.included(klass)
      # each topic or content item lives in exactly one basket
      klass.send :belongs_to, :basket

      # relate to topics
      klass.send :include, RelatedContent

      # where we handle creator and contributor tracking
      klass.send :include, HasContributors

      # all our ZOOM_CLASSES need this to be searchable by zebra
      klass.send :include, ConfigureActsAsZoomForKete

      # methods related to handling the xml kept in extended_content column
      klass.send :include, ExtendedContent

      klass.send :acts_as_versioned

      klass.send :acts_as_taggable

      klass.send :validates_presence_of, :title

      # this probably should change, particularly in still_image case
      klass.send :validates_uniqueness_of, :title

      # TODO: globalize stuff, uncomment later
      # translates :title, :description
    end
  end
end