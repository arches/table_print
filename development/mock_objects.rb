module TablePrint
  module Development
    module MockObjects
      # TODO: how to document these?

      class TestClass
        attr_accessor :title, :name, :blogs, :locker

        def initialize(title, name, blogs, locker)
          self.title = title
          self.name = name
          self.blogs = blogs
          self.locker = locker
        end
      end

      class Blog
        attr_accessor :title, :summary

        def initialize(title, summary)
          self.title = title
          self.summary = summary
        end
      end

      class Locker
        attr_accessor :assets

        def initialize(assets)
          self.assets = assets
        end
      end

      class Asset
        attr_accessor :url, :caption

        def initialize(url, caption)
          self.url = url
          self.caption = caption
        end
      end

      def stack
        [
            TestClass.new("one title", "one name", [
                Blog.new("one blog title1", "one blog sum1"),
                Blog.new("one blog title2", "one blog sum2"),
                Blog.new("one blog title3", "one blog sum3"),
            ],
                          Locker.new([
                                         Asset.new("one asset url1", "one asset cap1"),
                                         Asset.new("one asset url2", "one asset cap2"),
                                         Asset.new("one asset url3", "one asset cap3"),
                                     ])
            ),
            TestClass.new("two title", "two name", [
                Blog.new("two blog title1", "two blog sum1"),
                Blog.new("two blog title2", "two blog sum2"),
                Blog.new("two blog title3", "two blog sum3"),
            ],
                          Locker.new([
                                         Asset.new("two asset url1", "two asset cap1"),
                                         Asset.new("two asset url2", "two asset cap2"),
                                         Asset.new("two asset url3", "two asset cap3"),
                                     ])
            ),
            TestClass.new("three title", "three name", [
                Blog.new("three blog title1", "three blog sum1"),
                Blog.new("three blog title2", "three blog sum2"),
                Blog.new("three blog title3", "three blog sum3"),
            ],
                          Locker.new([
                                         Asset.new("three asset url1", "three asset cap1"),
                                         Asset.new("three asset url2", "three asset cap2"),
                                         Asset.new("three asset url3", "three asset cap3"),
                                     ])
            ),
            TestClass.new("four title", "four name", [
                Blog.new("four blog title1", "four blog sum1"),
                Blog.new("four blog title2", "four blog sum2"),
                Blog.new("four blog title3", "four blog sum3"),
            ],
                          Locker.new([
                                         Asset.new("four asset url1", "four asset cap1"),
                                         Asset.new("four asset url2", "four asset cap2"),
                                         Asset.new("four asset url3", "four asset cap3"),
                                     ])
            ),
        ]
      end
    end
  end
end
