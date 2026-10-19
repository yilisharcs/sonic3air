/*
*	rmx Library
*	Copyright (C) 2008-2026 by Eukaryot
*
*	Published under the GNU GPLv3 open source software license, see license.txt
*	or https://www.gnu.org/licenses/gpl-3.0.en.html
*/

#pragma once


#include "rmxbase/base/Types.h"

#include <cstring>

#if defined(PLATFORM_VITA)
	#include <psp2/kernel/clib.h>
#endif


namespace rmx
{
#if !defined(__vita__)

	// prefer memcpy over *(T*) because a typed dereference presumes alignment that callers cannot
	// guarantee, thus UBSan flags it
	template<typename T>
	T readMemoryUnaligned(const void* pointer)
	{
		T value;
		std::memcpy(&value, pointer, sizeof(T));
		return value;
	}

	template<typename T>
	T readMemoryUnalignedSwapped(const void* pointer)
	{
		return swapBytes<T>(readMemoryUnaligned<T>(pointer));
	}
#else
	template<typename T>
	T readMemoryUnaligned(const void* pointer)
	{
		T val;
		sceClibMemcpy(&val, pointer, sizeof(T));
		return val;
	}

	template<typename T>
	T readMemoryUnalignedSwapped(const void* pointer)
	{
		T val;
		sceClibMemcpy(&val, pointer, sizeof(T));
		return swapBytes<T>(val);
	}
#endif

#if defined(__arm__) && !defined(__vita__)
	template<> uint16 readMemoryUnaligned(const void* pointer);
	template<> uint32 readMemoryUnaligned(const void* pointer);
	template<> uint64 readMemoryUnaligned(const void* pointer);

	template<> uint16 readMemoryUnalignedSwapped(const void* pointer);
	template<> uint32 readMemoryUnalignedSwapped(const void* pointer);
	template<> uint64 readMemoryUnalignedSwapped(const void* pointer);
#endif
}
