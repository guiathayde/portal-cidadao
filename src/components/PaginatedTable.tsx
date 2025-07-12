'use client';

import { useState } from 'react';
import Pagination from '@/components/Pagination';
import { paginateData } from '@/lib/pagination';

interface PaginatedTableProps<T> {
  data: T[];
  columns: {
    key: keyof T | string;
    label: string;
    render?: (item: T, value: any) => React.ReactNode;
  }[];
  itemsPerPage?: number;
  className?: string;
  onRowClick?: (item: T) => void;
}

export default function PaginatedTable<T>({
  data,
  columns,
  itemsPerPage = 10,
  className = '',
  onRowClick,
}: PaginatedTableProps<T>) {
  const [currentPage, setCurrentPage] = useState(1);
  const paginatedData = paginateData(data, currentPage, itemsPerPage);

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const getValue = (item: T, key: keyof T | string): any => {
    if (typeof key === 'string' && key.includes('.')) {
      // Handle nested keys like 'user.name'
      return key.split('.').reduce((obj, k) => obj?.[k], item as any);
    }
    return item[key as keyof T];
  };

  return (
    <div className={className}>
      <div className="overflow-x-auto">
        <table className="min-w-full bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg">
          <thead className="bg-gray-50 dark:bg-gray-700">
            <tr>
              {columns.map((column, index) => (
                <th
                  key={index}
                  className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider"
                >
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            {paginatedData.data.map((item, index) => (
              <tr
                key={index}
                className={`hover:bg-gray-50 dark:hover:bg-gray-700 ${
                  onRowClick ? 'cursor-pointer' : ''
                }`}
                onClick={() => onRowClick?.(item)}
              >
                {columns.map((column, colIndex) => {
                  const value = getValue(item, column.key);
                  return (
                    <td
                      key={colIndex}
                      className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-300"
                    >
                      {column.render ? column.render(item, value) : value}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Pagination
        currentPage={paginatedData.currentPage}
        totalPages={paginatedData.totalPages}
        totalItems={paginatedData.totalItems}
        itemsPerPage={paginatedData.itemsPerPage}
        startIndex={paginatedData.startIndex}
        endIndex={paginatedData.endIndex}
        onPageChange={handlePageChange}
      />
    </div>
  );
}
