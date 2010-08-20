#include "../vendor/gc/include/gc.h"
#include "../vendor/gc/include/gc_cpp.h"
#include "../vendor/gc/include/gc_allocator.h"

#include "callable.h"
#include "fancy_object.h"
#include "errors.h"

namespace fancy {

  void Callable::check_sender_access(const std::string &method_name, FancyObject* receiver, FancyObject* sender) {
    // take care of private & protected methods
    if(_private) {
      if(sender->get_class() != receiver->get_class()) {
        throw new MethodNotFoundError(method_name, receiver->get_class(), "private method");
      }
    }
    if(_protected) {
      if(!sender->get_class()->subclass_of(receiver->get_class())) {
        throw new MethodNotFoundError(method_name, receiver->get_class(), "protected method");
      }
    }
  }

}