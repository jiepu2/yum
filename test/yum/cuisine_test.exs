defmodule Yum.CuisineTest do
    use ExUnit.Case

    setup do
        %{
            cuisines: %{
                "one" => %{
                    :__info__ => %{ "type" => "test" },
                    "foo" => %{
                        :__info__ => %{
                            "translation" => %{ "en" => %{ "term" => "1" } },
                            "type" => "country",
                            "cuisine" => %{
                                "a" => %{ "translation" => %{ "en" => %{ "term" => "a1" } } },
                                "b" => %{ "translation" => %{ "en" => %{ "term" => "b1" } } }
                            }
                        },
                        "bar-a" => %{ :__info__ => %{} },
                        "bar-b" => %{ :__info__ => %{ "type" => "subregion" } },
                        "bar-c" => %{
                            :__info__ => %{ "type" => "continent" },
                            "test" => %{ :__info__ => %{ "type" => "province" } }
                        }
                    }
                },
                "two" => %{},
                "three" => %{
                    :__info__ => %{
                        "translation" => %{ "en" => %{ "term" => "2" } },
                        "cuisine" => %{
                            "c" => %{ "translation" => %{ "en" => %{ "term" => "c1" } } },
                        },
                        "type" => "culture"
                    },
                    "foo" => %{
                        :__info__ => %{
                            "translation" => %{ "en" => %{ "term" => "1" } },
                            "cuisine" => %{
                                "d" => %{ "translation" => %{ "en" => %{ "term" => "d1" } } },
                            }
                        }
                    }
                }
            }
        }
    end

    test "new/1", %{ cuisines: cuisines } do
        assert [
            %Yum.Cuisine.Style{ ref: "/one", type: :other },
            %Yum.Cuisine.Style{ ref: "/one/foo", translation: %{ "en" => %{ "term" => "1" } }, type: :country, foods: [%Yum.Cuisine.Food{ ref: "a", translation: %{ "en" => %{ "term" => "a1" } } }, %Yum.Cuisine.Food{ ref: "b", translation: %{ "en" => %{ "term" => "b1" } } }] },
            %Yum.Cuisine.Style{ ref: "/one/foo/bar-a" },
            %Yum.Cuisine.Style{ ref: "/one/foo/bar-b", type: :subregion },
            %Yum.Cuisine.Style{ ref: "/one/foo/bar-c", type: :continent },
            %Yum.Cuisine.Style{ ref: "/one/foo/bar-c/test", type: :province },
            %Yum.Cuisine.Style{ ref: "/three", translation: %{ "en" => %{ "term" => "2" } }, type: :culture, foods: [%Yum.Cuisine.Food{ ref: "c", translation: %{ "en" => %{ "term" => "c1" } } }] },
            %Yum.Cuisine.Style{ ref: "/three/foo", translation: %{ "en" => %{ "term" => "1" } }, foods: [%Yum.Cuisine.Food{ ref: "d", translation: %{ "en" => %{ "term" => "d1" } } }] },
        ] == Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref))

        assert [] == Yum.Cuisine.Style.new(%{})
        assert [%Yum.Cuisine.Style{ ref: "/test", type: :province }] == Yum.Cuisine.Style.new(cuisines["one"]["foo"]["bar-c"])
    end

    test "name/1", %{ cuisines: cuisines } do
        assert [
            "one",
            "foo",
            "bar-a",
            "bar-b",
            "bar-c",
            "test",
            "three",
            "foo",
        ] == Enum.map(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)), &Yum.Cuisine.Style.name/1)

        assert ["test"] == Enum.map(Yum.Cuisine.Style.new(cuisines["one"]["foo"]["bar-c"]), &Yum.Cuisine.Style.name/1)
    end

    test "group_ref/1", %{ cuisines: cuisines } do
        assert [
            nil,
            "/one",
            "/one/foo",
            "/one/foo",
            "/one/foo",
            "/one/foo/bar-c",
            nil,
            "/three",
        ] == Enum.map(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)), &Yum.Cuisine.Style.group_ref/1)

        assert [nil] == Enum.map(Yum.Cuisine.Style.new(cuisines["one"]["foo"]["bar-c"]), &Yum.Cuisine.Style.group_ref/1)
    end

    test "ref_hash/2", %{ cuisines: cuisines } do
        assert 8 == Enum.count(Enum.uniq(Enum.map(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)), &Yum.Cuisine.Style.ref_hash/1)))

        cuisine_test = List.last(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)))

        assert [Yum.Cuisine.Style.ref_hash(cuisine_test)] != Enum.map(Yum.Cuisine.Style.new(cuisines["one"]["foo"]["bar-c"]), &Yum.Cuisine.Style.group_ref/1)
        assert Yum.Cuisine.Style.ref_hash(cuisine_test) == Yum.Cuisine.Style.ref_hash(%{ cuisine_test | translation: %{ "en" => %{ "term" => "1" } } })
    end

    test "ref_encode/2", %{ cuisines: cuisines } do
        assert 8 == Enum.count(Enum.uniq(Enum.map(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)), &Yum.Cuisine.Style.ref_encode/1)))

        cuisine_test = List.last(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)))

        assert [Yum.Cuisine.Style.ref_encode(cuisine_test)] != Enum.map(Yum.Cuisine.Style.new(cuisines["one"]["foo"]["bar-c"]), &Yum.Cuisine.Style.group_ref/1)
        assert Yum.Cuisine.Style.ref_encode(cuisine_test) == Yum.Cuisine.Style.ref_encode(%{ cuisine_test | translation: %{ "en" => %{ "term" => "1" } } })

        assert [
            "/one",
            "/one/foo",
            "/one/foo/bar-a",
            "/one/foo/bar-b",
            "/one/foo/bar-c",
            "/one/foo/bar-c/test",
            "/three",
            "/three/foo",
        ] == Enum.map(Enum.map(Enum.sort(Yum.Cuisine.Style.new(cuisines), &(&1.ref < &2.ref)), &Yum.Cuisine.Style.ref_encode/1), &Yum.Cuisine.Style.ref_decode/1)
    end
end
