import os
import sys


CHAKRA_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "../../../..", "extern/graph_frontend/chakra")
)
sys.path.insert(0, os.path.join(CHAKRA_ROOT, "schema", "protobuf"))
sys.path.insert(0, os.path.join(CHAKRA_ROOT, "src", "third_party", "utils"))

from et_def_pb2 import (
    ALL_REDUCE,
    COMM_COLL_NODE,
    COMP_NODE,
    AttributeProto as ChakraAttr,
    BoolList,
    GlobalMetadata,
    Node as ChakraNode,
)
from protolib import encodeMessage as encode_message


def main() -> None:
    for rank in range(4):
        collective = ChakraNode(id=0, name="tp_all_reduce", type=COMM_COLL_NODE)
        collective.attr.extend(
            [
                ChakraAttr(name="is_cpu_op", bool_val=False),
                ChakraAttr(name="comm_type", int64_val=ALL_REDUCE),
                ChakraAttr(name="comm_size", int64_val=4096),
                ChakraAttr(
                    name="involved_dim", bool_list=BoolList(values=[True])
                ),
            ]
        )

        tail = ChakraNode(id=1, name=f"rank_{rank}_tail", type=COMP_NODE)
        tail.attr.append(ChakraAttr(name="is_cpu_op", bool_val=False))
        tail.duration_micros = 1000 if rank == 1 else 10
        tail.data_deps.append(collective.id)

        with open(f"tp_tail.{rank}.et", "wb") as stream:
            encode_message(stream, GlobalMetadata(version="0.0.4"))
            encode_message(stream, collective)
            encode_message(stream, tail)


if __name__ == "__main__":
    main()
